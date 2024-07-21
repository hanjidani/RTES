#include <boost/beast/core.hpp>
#include <boost/beast/http.hpp>
#include <boost/beast/version.hpp>
#include <boost/asio.hpp>
#include <boost/algorithm/string.hpp>
#include <nlohmann/json.hpp>
#include <mysql_driver.h>
#include <mysql_connection.h>
#include <cppconn/statement.h>
#include <cppconn/prepared_statement.h>
#include <cppconn/resultset.h>
#include <fstream>
#include <iostream>

using tcp = boost::asio::ip::tcp;
namespace http = boost::beast::http;
namespace net = boost::asio;
using json = nlohmann::json;

class WebServer : public std::enable_shared_from_this<WebServer> {
    tcp::socket socket_;
    sql::mysql::MySQL_Driver* driver_;
    std::unique_ptr<sql::Connection> conn_;

public:
    WebServer(tcp::socket socket)
        : socket_(std::move(socket)), driver_(sql::mysql::get_mysql_driver_instance()) {
        try {
            conn_.reset(driver_->connect("tcp://127.0.0.1:3306", "user", "password"));
            conn_->setSchema("database_name");
        } catch (sql::SQLException &e) {
            std::cerr << "MySQL connection error: " << e.what() << std::endl;
            throw;
        }
    }

    void start() {
        read_request();
    }

private:
    void read_request() {
        auto self(shared_from_this());
        http::async_read(socket_, buffer_, req_,
            [self](boost::system::error_code ec, std::size_t bytes_transferred) {
                boost::ignore_unused(bytes_transferred);
                if (!ec)
                    self->handle_request();
                else
                    std::cerr << "Error reading request: " << ec.message() << std::endl;
            });
    }

    void handle_request() {
        if (req_.method() == http::verb::get) {
            if (req_.target() == "/") {
                serve_main_page();
            } else if (req_.target() == "/get-data") {
                serve_data();
            } else if (req_.target().starts_with("/add")) {
                handle_add();
            } else if (req_.target().starts_with("/status")) {
                handle_status();
            } else {
                send_bad_response();
            }
        } else {
            send_bad_response();
        }
    }

    void serve_main_page() {
        std::ifstream file("index.html");
        std::string html((std::istreambuf_iterator<char>(file)), std::istreambuf_iterator<char>());

        http::response<http::string_body> res{http::status::ok, req_.version()};
        res.set(http::field::server, BOOST_BEAST_VERSION_STRING);
        res.set(http::field::content_type, "text/html");
        res.body() = html;
        res.prepare_payload();
        auto self = shared_from_this();
        http::async_write(socket_, res,
            [self](boost::system::error_code ec, std::size_t) {
                self->socket_.shutdown(tcp::socket::shutdown_send, ec);
            });
    }

    void serve_data() {
        try {
            std::unique_ptr<sql::Statement> stmt(conn_->createStatement());
            std::unique_ptr<sql::ResultSet> res(stmt->executeQuery("SELECT * FROM events"));

            json data = json::array();
            while (res->next()) {
                json row;
                row["id"] = res->getInt("id");
                row["file_name"] = res->getString("file_name");
                row["event_name"] = res->getString("event_name");
                row["time"] = res->getString("time");
                data.push_back(row);
            }

            http::response<http::string_body> res{http::status::ok, req_.version()};
            res.set(http::field::server, BOOST_BEAST_VERSION_STRING);
            res.set(http::field::content_type, "application/json");
            res.body() = data.dump();
            res.prepare_payload();
            auto self = shared_from_this();
            http::async_write(socket_, res,
                [self](boost::system::error_code ec, std::size_t) {
                    self->socket_.shutdown(tcp::socket::shutdown_send, ec);
                });
        } catch (sql::SQLException &e) {
            std::cerr << "MySQL error: " << e.what() << std::endl;
            send_bad_response();
        }
    }

    void handle_add() {
        std::string query = req_.target().to_string();
        std::string file_name, event_name, time;
        parse_query(query, file_name, event_name, time);

        try {
            std::unique_ptr<sql::PreparedStatement> pstmt(conn_->prepareStatement("INSERT INTO events(file_name, event_name, time) VALUES (?, ?, ?)"));
            pstmt->setString(1, file_name);
            pstmt->setString(2, event_name);
            pstmt->setString(3, time);
            pstmt->execute();
            send_response("Event added successfully.");
        } catch (sql::SQLException &e) {
            std::cerr << "MySQL error: " << e.what() << std::endl;
            send_response("Failed to add event.");
        }
    }

    void handle_status() {
        std::string query = req_.target().to_string();
        std::string cpu_usage, ram_usage, time;
        parse_query(query, cpu_usage, ram_usage, time);

        try {
            std::unique_ptr<sql::PreparedStatement> pstmt(conn_->prepareStatement("INSERT INTO status(cpu_usage, ram_usage, time) VALUES (?, ?, ?)"));
            pstmt->setString(1, cpu_usage);
            pstmt->setString(2, ram_usage);
            pstmt->setString(3, time);
            pstmt->execute();
            send_response("Status added successfully.");
        } catch (sql::SQLException &e) {
            std::cerr << "MySQL error: " << e.what() << std::endl;
            send_response("Failed to add status.");
        }
    }

    void parse_query(const std::string& query, std::string& param1, std::string& param2, std::string& param3) {
        std::vector<std::string> params;
        boost::split(params, query, boost::is_any_of("&"));
        for (const auto& param : params) {
            std::vector<std::string> key_value;
            boost::split(key_value, param, boost::is_any_of("="));
            if (key_value.size() == 2) {
                if (key_value[0] == "file_name") param1 = key_value[1];
                else if (key_value[0] == "event_name") param2 = key_value[1];
                else if (key_value[0] == "time") param3 = key_value[1];
                else if (key_value[0] == "cpu_usage") param1 = key_value[1];
                else if (key_value[0] == "ram_usage") param2 = key_value[1];
            }
        }
    }

    void send_response(const std::string& message) {
        http::response<http::string_body> res{http::status::ok, req_.version()};
        res.set(http::field::server, BOOST_BEAST_VERSION_STRING);
        res.set(http::field::content_type, "text/plain");
        res.body() = message;
        res.prepare_payload();
        auto self = shared_from_this();
        http::async_write(socket_, res,
            [self](boost::system::error_code ec, std::size_t) {
                self->socket_.shutdown(tcp::socket::shutdown_send, ec);
            });
    }

    void send_bad_response() {
        http::response<http::string_body> res{http::status::bad_request, req_.version()};
        res.set(http::field::server, BOOST_BEAST_VERSION_STRING);
        res.set(http::field::content_type, "text/plain");
        res.body() = "Bad Request";
        res.prepare_payload();
        auto self = shared_from_this();
        http::async_write(socket_, res,
            [self](boost::system::error_code ec, std::size_t) {
                self->socket_.shutdown(tcp::socket::shutdown_send, ec);
            });
    }

    beast::flat_buffer buffer_;
    http::request<http::string_body> req_;
};

class Server {
    net::io_context& ioc_;
    tcp::acceptor acceptor_;

public:
    Server(net::io_context& ioc, tcp::endpoint endpoint)
        : ioc_(ioc), acceptor_(net::make_strand(ioc)) {
        beast::error_code ec;

        acceptor_.open(endpoint.protocol(), ec);
        if (ec) {
            fail(ec, "open");
            return;
        }

        acceptor_.set_option(net::socket_base::reuse_address(true), ec);
        if (ec) {
            fail(ec, "set_option");
            return;
        }

        acceptor_.bind(endpoint, ec);
        if (ec) {
            fail(ec, "bind");
            return;
        }

        acceptor_.listen(net::socket_base::max_listen_connections, ec);
        if (ec) {
            fail(ec, "listen");
            return;
        }

        do_accept();
    }

private:
    void do_accept() {
        acceptor_.async_accept(
            net::make_strand(ioc_),
            beast::bind_front_handler(
                &Server::on_accept,
                this));
    }

    void on_accept(beast::error_code ec, tcp::socket socket) {
        if (!ec) {
            std::make_shared<WebServer>(std::move(socket))->start();
        }

        do_accept();
    }

    void fail(beast::error_code ec, char const* what) {
        std::cerr << what << ": " << ec.message() << "\n";
    }
};

int main(int argc, char* argv[]) {
    try {
        if (argc != 3) {
            std::cerr << "Usage: WebServer <address> <port>\n";
            return 1;
        }

        auto const address = net::ip::make_address(argv[1]);
        auto const port = static_cast<unsigned short>(std::stoi(argv[2]));

        net::io_context ioc{1};

        Server server{ioc, tcp::endpoint{address, port}};

        ioc.run();
    }
    catch (const std::exception& e) {
        std::cerr << "Error: " << e.what() << std::endl;
        return 1;
    }
}
