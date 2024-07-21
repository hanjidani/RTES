#include <boost/beast/core.hpp>
#include <boost/beast/http.hpp>
#include <boost/beast/version.hpp>
#include <boost/asio.hpp>
#include <boost/config.hpp>
#include <iostream>
#include <memory>
#include <string>
#include <fstream>
#include <mysql_driver.h>
#include <mysql_connection.h>
#include <cppconn/statement.h>
#include <cppconn/prepared_statement.h>
#include <cppconn/resultset.h>
#include <nlohmann/json.hpp>
#include <boost/algorithm/string.hpp>
#include <sstream>
namespace beast = boost::beast;
namespace http = beast::http;
namespace net = boost::asio;
using tcp = boost::asio::ip::tcp;
using json = nlohmann::json;
#include <iostream>
#include <filesystem>

namespace fs = std::filesystem;

bool createDirectory(const std::string& folderPath) {
    try {
        if (fs::exists(folderPath)) {
            std::cout << "Directory already exists.\n";
            return true; // Directory already exists
        } else {
            fs::create_directory(folderPath);
            std::cout << "Directory created successfully.\n";
            return true; // Directory created successfully
        }
    } catch (const std::filesystem::filesystem_error& e) {
        std::cerr << "Error creating directory: " << e.what() << '\n';
        return false; // Failed to create directory
    }
}

std::string read_file(const std::string& filename) {
    std::ifstream ifs(filename, std::ios::binary);
    if (ifs) {
        std::ostringstream oss;
        oss << ifs.rdbuf();
        return oss.str();
    }
    return "";
}
class session : public std::enable_shared_from_this<session>
{
    tcp::socket socket_;
    beast::flat_buffer buffer_;
    http::request<http::string_body> req_;
    sql::mysql::MySQL_Driver* driver;
    std::unique_ptr<sql::Connection> con;

public:
    session(tcp::socket socket)
        : socket_(std::move(socket))
    {
        try {
            driver = sql::mysql::get_mysql_driver_instance();
            con = std::unique_ptr<sql::Connection>(driver->connect("tcp://127.0.0.1:3306", "root", ""));
            con->setSchema("audio_events_db");
        } catch (sql::SQLException &e) {
            std::cerr << "Error connecting to the database: " << e.what() << std::endl;
        }
    }

    void run()
    {
        do_read();
    }

private:
    void do_read()
    {
        beast::error_code ec;

        // Synchronous read
        http::read(socket_, buffer_, req_, ec);
        
        if (!ec)
            do_process();
        else
            fail(ec, "read");
    }

    void do_process()
    {
        if (req_.method() == http::verb::get && req_.target().starts_with("/add"))
        {
            handle_add();
        }
        else if (req_.method() == http::verb::get && req_.target().starts_with("/status"))
        {
            handle_status();
        }
        else if (req_.method() == http::verb::get && req_.target().starts_with("/temp"))
        {
            handle_temp();
        }
        else if (req_.method() == http::verb::get && req_.target() == "/api/events")
        {
            handle_get_events();
        }
        else if (req_.method() == http::verb::get && req_.target() == "/api/status")
        {
            handle_get_status();
        }
        else if (req_.method() == http::verb::get && req_.target() == "/api/microstatus")
        {
            handle_get_micro_status();
        }
        else if (req_.target() == "/")
        {
            serve_index();
        }else if (req_.method() == http::verb::get && req_.target().starts_with("/audio/")) {
            serve_audio();
        }
        else
        {
            send_bad_response();
        }
    }
        void serve_audio() {
        std::string audio_file = req_.target().to_string();
        std::string full_path = audio_file.erase(0,1);
        std::cout<<full_path<<std::endl;
        std::ifstream file(full_path.c_str(), std::ios::in | std::ios::binary);
        if (!file) {
            return send_bad_response(http::status::not_found, "Audio file not found");
        }

        std::stringstream ss;
        ss << file.rdbuf();
        std::string content = ss.str();

        http::response<http::string_body> res{http::status::ok, req_.version()};
        res.set(http::field::content_type, "audio/wav");
        res.body() = content;
        res.prepare_payload();

        return send_response(std::move(res));
    }
        void send_bad_response(http::status status, const std::string& message) {
        http::response<http::string_body> res{status, req_.version()};
        res.set(http::field::content_type, "text/plain");
        res.body() = message;
        res.prepare_payload();
        return send_response(std::move(res));
    }
void serve_index()
    {
        // Read index.html file into a string
        std::string content = read_file("index.html");

        // Create and send response
        http::response<http::string_body> res{http::status::ok, req_.version()};
        res.set(http::field::server, BOOST_BEAST_VERSION_STRING);
        res.set(http::field::content_type, "text/html");
        res.body() = content;
        res.prepare_payload();
        send_response(std::move(res));
    }
void handle_get_status()
    {
        if (!con) {
            send_internal_server_error();
            return;
        }

        try {
            std::unique_ptr<sql::Statement> stmt(con->createStatement());
            std::unique_ptr<sql::ResultSet> res(stmt->executeQuery("SELECT cpu_usage, ram_usage, time FROM device_status"));

            json j = json::array();
            while (res->next())
            {
                std::string cpu_usage = res->getString("cpu_usage");
                std::string ram_usage = res->getString("ram_usage");
                std::string time = res->getString("time");

                j.push_back({{"cpu_usage", cpu_usage}, {"ram_usage", ram_usage}, {"time", time}});
            }
            res->close();
            con->close();
            http::response<http::string_body> httpres{http::status::ok, req_.version()};
            httpres.set(http::field::server, BOOST_BEAST_VERSION_STRING);
            httpres.set(http::field::content_type, "application/json");
            httpres.body() = j.dump();
            httpres.prepare_payload();
            send_response(std::move(httpres));
        } catch (sql::SQLException &e) {
            std::cerr << "Error executing query: " << e.what() << std::endl;
            send_internal_server_error();
        }
    }

    void handle_get_micro_status()
    {
        if (!con) {
            send_internal_server_error();
            return;
        }

        try {
            std::unique_ptr<sql::Statement> stmt(con->createStatement());
            std::unique_ptr<sql::ResultSet> res(stmt->executeQuery("SELECT device, temp, time FROM micro_status"));

            json j = json::array();
            while (res->next())
            {
                std::string device = res->getString("device");
                std::string temp = res->getString("temp");
                std::string time = res->getString("time");

                j.push_back({{"device", device}, {"temp", temp}, {"time", time}});
            }
            res->close();
            con->close();
            http::response<http::string_body> httpres{http::status::ok, req_.version()};
            httpres.set(http::field::server, BOOST_BEAST_VERSION_STRING);
            httpres.set(http::field::content_type, "application/json");
            httpres.body() = j.dump();
            httpres.prepare_payload();
            send_response(std::move(httpres));
        } catch (sql::SQLException &e) {
            std::cerr << "Error executing query: " << e.what() << std::endl;
            send_internal_server_error();
        }
    }

    void handle_status()
    {
        if (!con) {
            send_internal_server_error();
            return;
        }

        std::string target = req_.target().to_string();
        std::map<std::string, std::string> query_params;
        
        auto pos = target.find("?");
        if (pos != std::string::npos)
        {
            std::string query_str = target.substr(pos + 1);
            std::vector<std::string> params;
            boost::split(params, query_str, boost::is_any_of("&"));

            for (const auto& param : params)
            {
                std::vector<std::string> key_value;
                boost::split(key_value, param, boost::is_any_of("="));
                if (key_value.size() == 2)
                {
                    query_params[key_value[0]] = key_value[1];
                }
            }
        }

        if (query_params.find("cpu_usage") != query_params.end() &&
            query_params.find("ram_usage") != query_params.end() &&
            query_params.find("time") != query_params.end())
        {
            try {
                std::string cpu_usage = query_params["cpu_usage"];
                std::string ram_usage = query_params["ram_usage"];
                std::string time = query_params["time"];

                std::unique_ptr<sql::PreparedStatement> pstmt(con->prepareStatement("INSERT INTO device_status (cpu_usage, ram_usage, time) VALUES (?, ?, ?)"));
                pstmt->setString(1, cpu_usage);
                pstmt->setString(2, ram_usage);
                pstmt->setString(3, time);
                pstmt->execute();

                http::response<http::string_body> res{http::status::ok, req_.version()};
                res.set(http::field::server, BOOST_BEAST_VERSION_STRING);
                res.set(http::field::content_type, "text/plain");
                res.body() = "Status added successfully";
                res.prepare_payload();
                send_response(std::move(res));
            } catch (sql::SQLException &e) {
                std::cerr << "Error executing query: " << e.what() << std::endl;
                send_internal_server_error();
            }
        }
        else
        {
            send_bad_response();
        }
    }
void handle_temp()
    {
        if (!con) {
            send_internal_server_error();
            return;
        }

        std::string target = req_.target().to_string();
        std::map<std::string, std::string> query_params;
        
        auto pos = target.find("?");
        if (pos != std::string::npos)
        {
            std::string query_str = target.substr(pos + 1);
            std::vector<std::string> params;
            boost::split(params, query_str, boost::is_any_of("&"));

            for (const auto& param : params)
            {
                std::vector<std::string> key_value;
                boost::split(key_value, param, boost::is_any_of("="));
                if (key_value.size() == 2)
                {
                    query_params[key_value[0]] = key_value[1];
                }
            }
        }

        if (query_params.find("temp") != query_params.end() &&
            query_params.find("device") != query_params.end() &&
            query_params.find("time") != query_params.end())
        {
            try {
                std::string temp = query_params["temp"];
                std::string device = query_params["device"];
                std::string time = query_params["time"];

                std::unique_ptr<sql::PreparedStatement> pstmt(con->prepareStatement("INSERT INTO micro_status (temp, device, time) VALUES (?, ?, ?)"));
                pstmt->setString(1, temp);
                pstmt->setString(2, device);
                pstmt->setString(3, time);
                pstmt->execute();

                http::response<http::string_body> res{http::status::ok, req_.version()};
                res.set(http::field::server, BOOST_BEAST_VERSION_STRING);
                res.set(http::field::content_type, "text/plain");
                res.body() = "Status added successfully";
                res.prepare_payload();
                send_response(std::move(res));
            } catch (sql::SQLException &e) {
                std::cerr << "Error executing query: " << e.what() << std::endl;
                send_internal_server_error();
            }
        }
        else
        {
            send_bad_response();
        }
    }
    void handle_add()
    {
        if (!con) {
            send_internal_server_error();
            return;
        }

        std::string target = req_.target().to_string();
        std::map<std::string, std::string> query_params;
        
        auto pos = target.find("?");
        if (pos != std::string::npos)
        {
            std::string query_str = target.substr(pos + 1);
            std::vector<std::string> params;
            boost::split(params, query_str, boost::is_any_of("&"));

            for (const auto& param : params)
            {
                std::vector<std::string> key_value;
                boost::split(key_value, param, boost::is_any_of("="));
                if (key_value.size() == 2)
                {
                    query_params[key_value[0]] = key_value[1];
                }
            }
        }

        if (query_params.find("filename") != query_params.end() &&
            query_params.find("time") != query_params.end() &&
            query_params.find("event_name") != query_params.end())
        {
            try {
                std::string filename = query_params["filename"];
                std::string time = query_params["time"];
                std::string event_name = query_params["event_name"];
                std::string wave_data = req_.body();

                std::ofstream ofs("audio/" + filename, std::ios::binary);
                ofs << wave_data;
                ofs.close();

                std::unique_ptr<sql::PreparedStatement> pstmt(con->prepareStatement("INSERT INTO audio_events (device_number, filename, event_time, event_name, time) VALUES (?, ?, ?, ?, ?)"));
                pstmt->setInt(1, 1); // You can change this as per your requirement
                pstmt->setString(2, filename);
                pstmt->setString(3, time);
                pstmt->setString(4, event_name);
                pstmt->setString(5, std::to_string(std::time(0)));
                pstmt->execute();

                http::response<http::string_body> res{http::status::ok, req_.version()};
                res.set(http::field::server, BOOST_BEAST_VERSION_STRING);
                res.set(http::field::content_type, "text/plain");
                res.body() = "File added successfully";
                res.prepare_payload();
                send_response(std::move(res));
            } catch (sql::SQLException &e) {
                std::cerr << "Error executing query: " << e.what() << std::endl;
                send_internal_server_error();
            }
        }
        else
        {
            send_bad_response();
        }
    }

    void handle_get_events()
    {
        if (!con) {
            send_internal_server_error();
            return;
        }

        try {
            std::unique_ptr<sql::Statement> stmt(con->createStatement());
            std::unique_ptr<sql::ResultSet> res(stmt->executeQuery("SELECT device_number, filename, event_time, event_name, time FROM audio_events"));

            json j = json::array();
            while (res->next())
            {
                int device_number = res->getInt("device_number");
                std::string filename = res->getString("filename");
                std::string event_time = res->getString("event_time");
                std::string event_name = res->getString("event_name");
                std::string time = res->getString("time");
                j.push_back({{"device_number", device_number}, {"filename", filename}, {"event_time", event_time}, {"event_name", event_name},{"time", time} });
            }

            http::response<http::string_body> httpres{http::status::ok, req_.version()};
            httpres.set(http::field::server, BOOST_BEAST_VERSION_STRING);
            httpres.set(http::field::content_type, "application/json");
            httpres.body() = j.dump();
            httpres.prepare_payload();
            send_response(std::move(httpres));
        } catch (sql::SQLException &e) {
            std::cerr << "Error executing query: " << e.what() << std::endl;
            send_internal_server_error();
        }
    }

    void send_bad_response()
    {
        http::response<http::string_body> res{http::status::bad_request, req_.version()};
        res.set(http::field::server, BOOST_BEAST_VERSION_STRING);
        res.set(http::field::content_type, "text/plain");
        res.body() = "Bad request";
        res.prepare_payload();
        send_response(std::move(res));
    }

    void send_internal_server_error()
    {
        http::response<http::string_body> res{http::status::internal_server_error, req_.version()};
        res.set(http::field::server, BOOST_BEAST_VERSION_STRING);
        res.set(http::field::content_type, "text/plain");
        res.body() = "Internal server error";
        res.prepare_payload();
        send_response(std::move(res));
    }

    void fail(beast::error_code ec, char const* what)
    {
        std::cerr << what << ": " << ec.message() << std::endl;
    }

    void send_response(http::response<http::string_body>&& res)
    {
        beast::error_code ec;
        
        // Synchronous write
        http::write(socket_, res, ec);
        
        if (ec)
        {
            fail(ec, "write");
        }
    }
};

class server
{
    net::io_context& ioc_;
    tcp::acceptor acceptor_;

public:
    server(net::io_context& ioc, tcp::endpoint endpoint)
        : ioc_(ioc), acceptor_(ioc)
    {
        beast::error_code ec;

        acceptor_.open(endpoint.protocol(), ec);
        if (ec)
        {
            fail(ec, "open");
            return;
        }

        acceptor_.set_option(net::socket_base::reuse_address(true), ec);
        if (ec)
        {
            fail(ec, "set_option");
            return;
        }

        acceptor_.bind(endpoint, ec);
        if (ec)
        {
            fail(ec, "bind");
            return;
        }

        acceptor_.listen(net::socket_base::max_listen_connections, ec);
        if (ec)
        {
            fail(ec, "listen");
            return;
        }

        do_accept();
    }

private:
    void do_accept()
    {
        while (true)
        {
            beast::error_code ec;
            tcp::socket socket(ioc_);
            acceptor_.accept(socket, ec);

            if (!ec)
                std::make_shared<session>(std::move(socket))->run();
            else
                fail(ec, "accept");
        }
    }

    void fail(beast::error_code ec, char const* what)
    {
        std::cerr << what << ": " << ec.message() << std::endl;
    }
};

int main()
{
    try
    {
        createDirectory("audio");
        auto const address = net::ip::make_address("0.0.0.0");
        unsigned short port = static_cast<unsigned short>(8080);

        net::io_context ioc{1};
        server srv{ioc, {address, port}};
        ioc.run();
    }
    catch (const std::exception& e)
    {
        std::cerr << "Error: " << e.what() << std::endl;
        return EXIT_FAILURE;
    }
}
