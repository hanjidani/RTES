#include <iostream>
#include <ctime>
#include <mysql_driver.h>
#include <mysql_connection.h>
#include <cppconn/driver.h>
#include <cppconn/exception.h>
#include <cppconn/prepared_statement.h>
#include <mosquitto.h>

#define ADDRESS     "localhost"
#define PORT        1883
#define CLIENTID    "mqtt_to_mysql"
#define TOPIC       "micro/temp"
#define QOS         1
#define TIMEOUT     10000L

using namespace std;
using namespace sql;

// MySQL database details
const string DB_HOST = "tcp://127.0.0.1:3306";
const string DB_USER = "root";
const string DB_PASS = "";
const string DB_NAME = "audio_events_db";

// Callback when a message arrives
void on_message(struct mosquitto *mosq, void *userdata, const struct mosquitto_message *message) {
    char* payload = (char*) message->payload;
    cout << "Message arrived on topic: " << message->topic << " Message: " << payload << endl;

    // Insert message into MySQL database
    try {
        mysql::MySQL_Driver *driver;
        Connection *con;
        PreparedStatement *pstmt;

        driver = mysql::get_mysql_driver_instance();
        con = driver->connect(DB_HOST, DB_USER, DB_PASS);
        con->setSchema(DB_NAME);

        pstmt = con->prepareStatement("INSERT INTO micro_status(device, temp, time) VALUES (?, ?, ?)");
        pstmt->setString(1, "1");
        pstmt->setString(2, payload);
        pstmt->setString(3, std::to_string(std::time(0))); // Get current time as string
        pstmt->execute();

        delete pstmt;
        delete con;
    } catch (SQLException &e) {
        cout << "MySQL error: " << e.what() << endl;
    }
}

int main(int argc, char* argv[]) {
    struct mosquitto *mosq = NULL;
    int rc;

    mosquitto_lib_init();

    mosq = mosquitto_new(CLIENTID, true, NULL);
    if (!mosq) {
        cerr << "Error: Out of memory." << endl;
        return 1;
    }

    mosquitto_message_callback_set(mosq, on_message);

    rc = mosquitto_connect(mosq, ADDRESS, PORT, TIMEOUT);
    if (rc != MOSQ_ERR_SUCCESS) {
        cerr << "Unable to connect to MQTT broker. Error code: " << rc << endl;
        return 1;
    }
    cout << "Connected to MQTT broker at " << ADDRESS << ":" << PORT << endl;

    rc = mosquitto_subscribe(mosq, NULL, TOPIC, QOS);
    if (rc != MOSQ_ERR_SUCCESS) {
        cerr << "Failed to subscribe to topic " << TOPIC << ". Error code: " << rc << endl;
        mosquitto_destroy(mosq);
        mosquitto_lib_cleanup();
        return 1;
    }
    cout << "Subscribed to topic: " << TOPIC << endl;

    // Keep the client running to handle messages
    rc = mosquitto_loop_forever(mosq, -1, 1);

    mosquitto_destroy(mosq);
    mosquitto_lib_cleanup();

    return rc;
}
