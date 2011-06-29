#include "request.h"
#include "HTTPClient.h"

HTTPClient http;
static char url[40];

bool request(const char *arg, char *response) {
    if (!arg || strlen(arg) < 1) return false;

    sprintf(url, "http://192.168.77.43:45678/code/%s", arg);
    //sprintf(url, "http://mbed.org/media/uploads/donatien/hello.txt");
    //sprintf(url, "http://192.168.77.141:3456/");

    HTTPText text("text/plain");
    HTTPResult r = http.get(url, &text);
    if ( r == HTTP_OK ) {
        strncpy(response, text.gets(), 128);
        return true;
    } else {
        return false;
    }
}

