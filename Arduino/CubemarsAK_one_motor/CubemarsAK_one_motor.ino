
#include <mcp_can.h>

#ifdef ARDUINO_SAMD_VARIANT_COMPLIANCE
#define SERIAL SerialUSB
#else
#define SERIAL Serial
#endif

// Value Limits
#define P_MIN -12.5f
#define P_MAX 12.5f
#define V_MIN -30.0f
#define V_MAX 30.0f
#define KP_MIN 0.0f
#define KP_MAX 500.0f
#define KD_MIN 0.0f
#define KD_MAX 5.0f
#define T_MIN -18.0f
#define T_MAX 18.0f

// Set Initial Values
float p_in = 0.0f;
float v_in = 0.0f;
float kp_in = 60.0f;
float kd_in = 1.0f;
float t_in = 0.0f;

// Measured Values
float p_out = 0.0f;
float v_out = 0.0f;
float t_out = 0.0f;

unsigned long can_id = 0x01; //Motor ID
//(Default is set to 0x01)

// CAN commands
unsigned char MIT_ON[8] = 
{0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0XFC};
unsigned char MIT_OFF[8] = 
{0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0XFD};
unsigned char MIT_ZERO[8] = 
{0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0XFE};

MCP_CAN CAN0(53);  // Set CS to pin 53

void setup() {
  if (CAN0.begin(MCP_ANY,CAN_1000KBPS,MCP_8MHZ) == CAN_OK)
    Serial.println("CAN Init OK!");
  else
    Serial.println("CAN Init Failed!");
  CAN0.setMode(MCP_NORMAL);
  CAN0.sendMsgBuf(can_id,0,8, MIT_OFF);
  CAN0.sendMsgBuf(can_id,0,8, MIT_ON);
  CAN0.sendMsgBuf(can_id,0,8, MIT_ZERO);
}

void loop() {
    p_in = p_in + 0.005;
    if(CAN_MSGAVAIL == CAN0.checkReceive()) unpack_reply();
    pack_cmd();
}


void unpack_reply() {
  byte len = 0;
  byte buf[8];
  unsigned long canId;

  CAN0.readMsgBuf(&canId,&len,buf);

  unsigned int id = buf[0];
  unsigned int p_int = (buf[1]<<8)|buf[2];
  unsigned int v_int = (buf[3]<<4)|(buf[4]>>4);
  unsigned int i_int = ((buf[4]&0xF)<<8)|buf[5];
  p_out = uint_to_float(p_int,P_MIN,P_MAX,16);
  v_out = uint_to_float(v_int,V_MIN,V_MAX,12);
  t_out = uint_to_float(i_int,T_MIN,T_MAX,12);
}

void pack_cmd(){
  byte buf[8];
  // Limit data to be withing bounds
  float p_des = constrain(p_in,P_MIN,P_MAX); 
  float v_des = constrain(v_in,V_MIN,V_MAX); 
  float kp = constrain(kp_in,KP_MIN,KP_MAX);
  float kd = constrain(kd_in,KD_MIN,KD_MAX);
  float t_ff = constrain(t_in,T_MIN,T_MAX); 
  // Convert floats to unsigned ints
  unsigned int p_int = float_to_uint(p_des,P_MIN,P_MAX,16);
  unsigned int v_int = float_to_uint(v_des,V_MIN,V_MAX,12);
  unsigned int kp_int = float_to_uint(kp,KP_MIN,KP_MAX,12);
  unsigned int kd_int = float_to_uint(kd,KD_MIN,KD_MAX,12);
  unsigned int t_int = float_to_uint(t_ff,T_MIN,T_MAX,12);

  // Pack ints into the can buffer
  buf[0] = p_int >> 8;
  buf[1] = p_int & 0xFF;
  buf[2] = v_int >> 4;
  buf[3] = ((v_int & 0xF) << 4) | (kp_int >> 8);
  buf[4] = kp_int & 0xFF;
  buf[5] = kd_int >> 4;
  buf[6] = ((kd_int & 0xF) <<4) | (t_int >>8);
  buf[7] = t_int & 0xFF;
  CAN0.sendMsgBuf(can_id, 0, 8, buf);
}

unsigned int float_to_uint(float x,float x_min,
float x_max,int bits) 
{
  //Converts a  float to an unsigned int, given range 
  //and number of bits
  float span = x_max-x_min;
  x = constrain(x,x_min,x_max); 
  unsigned int pgg = 0;
  if(bits==12){
    pgg = (unsigned int) ((x-x_min)*4095.0/span);
  }
  if(bits==16){
    pgg = (unsigned int) ((x-x_min)*65535.0/span);
  }
  return pgg;
}

float uint_to_float(unsigned int x_int,float x_min, 
float x_max,int bits)
{
  //converts unsigned int to float, given range
  // and number of bits
  float span = x_max-x_min;
  float offset = x_min;
  float pgg = 0;
  if (bits==12){
    pgg = ((float) x_int)*span/4095 + offset;
  }
  if (bits==16){
    pgg = ((float) x_int)*span/65535.0 + offset;
  }
  return pgg;
}