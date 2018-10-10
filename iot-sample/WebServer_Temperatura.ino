#include <ESP8266WiFi.h>            // lib do wifi para o ESP8266
#include <ESP8266WiFiMulti.h>       // lib do wifi para o ESP8266
#include <ESP8266HTTPClient.h>      // lib do wifi para o ESP8266
#include "DHT.h"                    // lib do sensor DHT de temperatura

#define DHTPIN D1                   // Porta que o sensor esta conectado
#define DHTTYPE DHT11               // DHT 11

const char* ssid = "xxxx";          // nome da rede
const char* password = "xxxx";      // senha da rede
int icont = 0;                      // contador do processo
boolean lExecute = false;           // informa se o sensor esta ligado ou nao
String remoteUrl = "";              // url remota para enviar informacoes
float h = 0.0;                      // resultado da leitura da humidade
float t = 0.0;                      // resultado da leitura da temperatura

ESP8266WiFiMulti wifiMulti;         // Carrega o modulo de WIFI

WiFiServer server(80);              // Habilita um server na porta 80
HTTPClient http;                    // habilita o http client

DHT dht(DHTPIN, DHTTYPE);           // inicializa o sensor de temperatura

void setup() {
  Serial.begin(115200);             // Inicia a serial
  Serial.println("Booting");

  wifiMulti.addAP(ssid, password);  // Ativa a conexao via Wifi

  Serial.println("Connecting...");

  while (wifiMulti.run() != WL_CONNECTED) {    // Realiza a conexao Wifi
    delay(300);
    Serial.print('.');
  }

  // Start the server
  server.begin();                   // Inicia o servidor na porta 80
  Serial.println("Server started");
  
  Serial.println("Ready");
  Serial.print("iP address: ");
  Serial.println(WiFi.localIP());   // mostra o endereco ip da conexao WIFI

  dht.begin();                      // inicia o sensor DHT
}

void loop() {
  // faz a leitura do client
  if (wifiMulti.run() == WL_CONNECTED) {
    verifyClient();
  }

  // se tiver capturado um endereco ip remoto, mostra ele
  if (remoteUrl != "") {
    Serial.println("URL = " + remoteUrl);
  }

  if (lExecute) {
    h = dht.readHumidity();         // realiza a leitura da humidade
    t = dht.readTemperature();      // realiza a leitura da temperatura

    if (isnan(h) || isnan(t)) {
       //Serial.println("Failed to read from DHT sensor!");
       return;
    }

    Serial.print("Humidade: ");
    Serial.print(h);
    Serial.print(" %\t");
    Serial.print("Temperatura: ");
    Serial.print(t);
    Serial.println(" *C ");
  } else {
    Serial.println("Processando " + String(++icont));
    remoteUrl = "";
    h = 0.0;
    t = 0.0;
  }

  // envia informacoes para o server
  if (remoteUrl != "" && wifiMulti.run() == WL_CONNECTED) {
    sendInformation();
  }
  
  delay(1000);
}

void verifyClient() {
  String cCmd = "";
  String cRet = "";

  // Verifica se o client foi conectado
  WiFiClient client = server.available();
  if (!client) {
    return;
  }

  // le as informacoes passadas para o client
  String request = client.readStringUntil('\r');
  client.flush();

  String ipRemoto = client.remoteIP().toString();
  Serial.println("IpRemoto = " + ipRemoto);

  if (request.indexOf("/cap") != -1)  {         // captura o endereco ip remoto para enviar as informacoes
    cCmd = "CAP";
    cRet = "IP Capturado " + ipRemoto;
    remoteUrl = "http://" + ipRemoto + ":8181/";
  }
  if (request.indexOf("/on") != -1)  {          // liga a leitura do sensor
    cCmd = "ON";
    cRet = "Sensor Ligado!";
    lExecute = true;
  }
  if (request.indexOf("/off") != -1)  {         // desliga a leitura do sensor
    cCmd = "OFF";
    cRet = "Sensor Desligado!";
    lExecute = false;
  }
  if (request.indexOf("/get") != -1)  {         // retorna a leitura do sensor para quem solicitou
    cCmd = "GET";
    if  (lExecute) 
      cRet = "Humidade: " + String(h) + " - Temperatura: " + String(t);
    else
      cRet = "O Sensor esta Desligado!";
  }

  String s = "HTTP/1.1 200 OK\r\nContent-Type: text/html\r\nConnection: close\r\n\r\n<!DOCTYPE html><html><body><h1>" + cRet + "</h1></body></html>\n";
  client.print(s);
  delay(1);

  Serial.println("Comando recebido = " + cCmd);
}

void sendInformation() {
  if (remoteUrl != "") {
    http.begin(remoteUrl + "?humidade=" + String(h) + "&temperatura=" + String(t));  // Envia para a URL remota as informacoes do sensor

    Serial.print("[HTTP] GET...\n");
    // start connection and send HTTP header
    int httpCode = http.GET();

    // httpCode will be negative on error
    if (httpCode > 0) {
      // HTTP header has been send and Server response header has been handled
      Serial.printf("[HTTP] GET... code: %d\n", httpCode);

      // file found at server
      if (httpCode == HTTP_CODE_OK) {
        String payload = http.getString();
        Serial.println(payload);
      }
    } else {
      Serial.printf("[HTTP] GET... failed, error: %s\n", http.errorToString(httpCode).c_str());
      remoteUrl = "";
    }

    http.end();
  }
}
