#include <Dynamixel2Arduino.h>

// Define communication object
#define D2A_SERIAL Serial1

const float DXL_PROTOCOL_VERSION = 1.0;

// Create Dynamixel class object
Dynamixel2Arduino dxl(D2A_SERIAL);

// This namespace is required to use Control table item names
using namespace ControlTableItem;

void setup() {
  Serial.begin(115200);  // Serial monitor communication
  dxl.begin(1000000);    // Set baud rate to match Dynamixel motors
  dxl.setPortProtocolVersion(DXL_PROTOCOL_VERSION);

  Serial.println("Arduino ready. Commands: 'o' (on), 'f' (off), 'p' (positions)");
}

void setTorque(bool enable) {
  for (uint8_t id = 1; id <= 5; id++) {
    if (dxl.ping(id)) {
      dxl.writeControlTableItem(TORQUE_ENABLE, id, enable);
      Serial.print("Motor ");
      Serial.print(id);
      Serial.print(" Torque ");
      Serial.println(enable ? "Enabled" : "Disabled");
    }
  }
}

void reportCurrentPositions() {
  for (uint8_t id = 1; id <= 5; id++) {
    if (dxl.ping(id)) {
      uint16_t pos = dxl.readControlTableItem(PRESENT_POSITION, id);
      Serial.print("Motor ");
      Serial.print(id);
      Serial.print(" Position: ");
      Serial.println(pos);
    }
  }
}

void loop() {
  if (Serial.available()) {
    char command = Serial.read();

    if (command == 'o') {
      setTorque(true);
    } 
    else if (command == 'f') {
      setTorque(false);
    } 
    else if (command == 'p') {
      reportCurrentPositions();
    }
  }
}
