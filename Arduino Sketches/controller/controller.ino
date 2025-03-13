#include <Dynamixel2Arduino.h>

#define D2A_SERIAL Serial1
const float DXL_PROTOCOL_VERSION = 1.0;
Dynamixel2Arduino dxl(D2A_SERIAL);
using namespace ControlTableItem;

const uint8_t numMotors = 5;
uint16_t targetPositions[numMotors];  // Store target positions
uint16_t targetSpeeds[numMotors];     // Store target speeds

void setup() {
  Serial.begin(115200);
  dxl.begin(1000000);
  dxl.setPortProtocolVersion(DXL_PROTOCOL_VERSION);

  for (uint8_t id = 1; id <= numMotors; id++) {
    if (dxl.ping(id)) {
      dxl.writeControlTableItem(TORQUE_ENABLE, id, 1);
      Serial.print("Torque enabled for Motor ");
      Serial.println(id);
    }
  }
  Serial.println("Arduino is ready!");
}

void moveMotorsSimultaneously() {
  for (uint8_t id = 1; id <= numMotors; id++) {
    if (dxl.ping(id)) {
      dxl.writeControlTableItem(MOVING_SPEED, id, targetSpeeds[id - 1]);
    }
  }
  for (uint8_t id = 1; id <= numMotors; id++) {
    if (dxl.ping(id)) {
      dxl.setGoalPosition(id, targetPositions[id - 1]);
    }
  }
}

void loop() {
  if (Serial.available() >= numMotors * 4) {  // Wait for full data packet
    for (uint8_t i = 0; i < numMotors; i++) {
      uint8_t posLow = Serial.read();
      uint8_t posHigh = Serial.read();
      targetPositions[i] = (posHigh << 8) | posLow;

      uint8_t speedLow = Serial.read();
      uint8_t speedHigh = Serial.read();
      targetSpeeds[i] = (speedHigh << 8) | speedLow;
    }

    Serial.println("Moving Motors...");
    moveMotorsSimultaneously();

    // Send acknowledgment to MATLAB
    Serial.println("ACK");
  }
}
