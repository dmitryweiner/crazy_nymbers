#include "math.h"
#include "Time.h"  
#include "Bounce2.h"
#include <avr/pgmspace.h>
#include <EEPROM.h>

#define PIN_SCE   9
#define PIN_RESET 8
#define PIN_DC    10
#define PIN_SDIN  11
#define PIN_SCLK  12
#define PIN_ALARM 13


#define BUTTON_1  2
#define BUTTON_2  5
#define BUTTON_3  6
#define BUTTON_4  7

#define LCD_C     LOW
#define LCD_D     HIGH

#define LCD_X     84
#define LCD_Y     48

#define PIXEL_OFF 0
#define PIXEL_ON  1
#define PIXEL_XOR 2

#define LANG_RUS 0
#define LANG_RUS 1

static const byte ASCII_RUS[] PROGMEM =
{
  0x00, 0x00, 0x00, 0x00, 0x00 // 20  
  ,0x00, 0x00, 0x5f, 0x00, 0x00 // 21 !
  ,0x00, 0x07, 0x00, 0x07, 0x00 // 22 "
  ,0x14, 0x7f, 0x14, 0x7f, 0x14 // 23 #
  ,0x24, 0x2a, 0x7f, 0x2a, 0x12 // 24 $
  ,0x23, 0x13, 0x08, 0x64, 0x62 // 25 %
  ,0x36, 0x49, 0x55, 0x22, 0x50 // 26 &
  ,0x00, 0x05, 0x03, 0x00, 0x00 // 27 '
  ,0x00, 0x1c, 0x22, 0x41, 0x00 // 28 (
  ,0x00, 0x41, 0x22, 0x1c, 0x00 // 29 )
  ,0x14, 0x08, 0x3e, 0x08, 0x14 // 2a *
  ,0x08, 0x08, 0x3e, 0x08, 0x08 // 2b +
  ,0x00, 0x50, 0x30, 0x00, 0x00 // 2c ,
  ,0x08, 0x08, 0x08, 0x08, 0x08 // 2d -
  ,0x00, 0x60, 0x60, 0x00, 0x00 // 2e .
  ,0x20, 0x10, 0x08, 0x04, 0x02 // 2f /
  ,0x3e, 0x51, 0x49, 0x45, 0x3e // 30 0
  ,0x00, 0x42, 0x7f, 0x40, 0x00 // 31 1
  ,0x42, 0x61, 0x51, 0x49, 0x46 // 32 2
  ,0x21, 0x41, 0x45, 0x4b, 0x31 // 33 3
  ,0x18, 0x14, 0x12, 0x7f, 0x10 // 34 4
  ,0x27, 0x45, 0x45, 0x45, 0x39 // 35 5
  ,0x3c, 0x4a, 0x49, 0x49, 0x30 // 36 6
  ,0x01, 0x71, 0x09, 0x05, 0x03 // 37 7
  ,0x36, 0x49, 0x49, 0x49, 0x36 // 38 8
  ,0x06, 0x49, 0x49, 0x29, 0x1e // 39 9
  ,0x00, 0x36, 0x36, 0x00, 0x00 // 3a :
  ,0x00, 0x56, 0x36, 0x00, 0x00 // 3b ;
  ,0x08, 0x14, 0x22, 0x41, 0x00 // 3c <
  ,0x14, 0x14, 0x14, 0x14, 0x14 // 3d =
  ,0x00, 0x41, 0x22, 0x14, 0x08 // 3e >
  ,0x02, 0x01, 0x51, 0x09, 0x06 // 3f ?
  ,0x46, 0x29, 0x19, 0x09, 0x7f // 40 @ = Я
  ,0x7e, 0x11, 0x11, 0x11, 0x7e // 41 A  
  ,0x7f, 0x49, 0x49, 0x49, 0x31 // 42 B = Б
  ,0x7f, 0x40, 0x40, 0x7f, 0xc0 // 43 C = Ц
  ,0xc0, 0x7f, 0x41, 0x7f, 0xc0 // 44 D = Д
  ,0x7f, 0x49, 0x49, 0x49, 0x41 // 45 E 
  ,0x0e, 0x11, 0x7f, 0x11, 0x0e // 46 F = Ф
  ,0x7f, 0x01, 0x01, 0x01, 0x01 // 47 G = Г
  ,0x63, 0x14, 0x08, 0x14, 0x63 // 48 H = Х
  ,0x7f, 0x10, 0x0c, 0x02, 0x7f // 49 I = И
  ,0x73, 0x0c, 0x7f, 0x0c, 0x73 // 4a J = Ж
  ,0x7f, 0x08, 0x14, 0x22, 0x41 // 4b K 
  ,0x40, 0x3e, 0x01, 0x01, 0x7f // 4c L = Л
  ,0x7f, 0x02, 0x0c, 0x02, 0x7f // 4d M
  ,0x7f, 0x08, 0x08, 0x08, 0x7f // 4e N = Н
  ,0x3e, 0x41, 0x41, 0x41, 0x3e // 4f O
  ,0x7f, 0x01, 0x01, 0x01, 0x7f // 50 P = П
  ,0x7f, 0x48, 0x48, 0x30, 0x00 // 51 Q = Ь
  ,0x7f, 0x09, 0x09, 0x09, 0x06 // 52 R = Р
  ,0x3e, 0x41, 0x41, 0x41, 0x22 // 53 S = С
  ,0x01, 0x01, 0x7f, 0x01, 0x01 // 54 T
  ,0x43, 0x4c, 0x30, 0x0c, 0x03 // 55 U = У
  ,0x7f, 0x49, 0x49, 0x49, 0x36 // 56 V = В
  ,0x7f, 0x40, 0x7f, 0x40, 0x7f // 57 W = Ш
  ,0x7f, 0x40, 0x7f, 0x40, 0xff // 58 X = Щ
  ,0x7f, 0x48, 0x30, 0x00, 0x7f // 59 Y = Ы
  ,0x41, 0x49, 0x49, 0x36, 0x00 // 5a Z = З
  ,0x01, 0x7f, 0x48, 0x48, 0x30 // 5b [ = Ъ
  ,0x7f, 0x08, 0x3e, 0x41, 0x3e // 5c ¥ = Ю
  ,0x49, 0x49, 0x49, 0x3e, 0x00 // 5d ] = Э
  ,0x07, 0x08, 0x08, 0x7f, 0x00 // 5e ^ = Ч
  ,0x7f, 0x10, 0x0d, 0x02, 0x7f // 5f _ = Й
  ,0x7c, 0x20, 0x14, 0x08, 0x7c // 60 ` = й
  ,0x20, 0x54, 0x54, 0x54, 0x78 // 61 a
  ,0x3c, 0x4a, 0x4b, 0x49, 0x30 // 62 b = б
  ,0x7c, 0x40, 0x40, 0x7c, 0xc0 // 63 c = ц
  ,0xc0, 0x7c, 0x44, 0x7c, 0xc0 // 64 d = д
  ,0x38, 0x54, 0x54, 0x54, 0x18 // 65 e
  ,0x18, 0x24, 0xfc, 0x24, 0x18 // 66 f = ф
  ,0x7c, 0x04, 0x04, 0x04, 0x00 // 67 g = г
  ,0x44, 0x28, 0x10, 0x28, 0x44 // 68 h = х
  ,0x7c, 0x20, 0x10, 0x08, 0x7c // 69 i = и
  ,0x44, 0x28, 0x7c, 0x28, 0x44 // 6a j = ж
  ,0x7c, 0x10, 0x28, 0x44, 0x00 // 6b k = к
  ,0x40, 0x3c, 0x04, 0x04, 0x7c // 6c l = л
  ,0x7c, 0x08, 0x10, 0x08, 0x7c // 6d m = м
  ,0x7c, 0x10, 0x10, 0x7c, 0x00 // 6e n = н
  ,0x38, 0x44, 0x44, 0x44, 0x38 // 6f o
  ,0x7c, 0x04, 0x04, 0x7c, 0x00 // 70 p = п
  ,0x7c, 0x50, 0x50, 0x20, 0x00 // 71 q = ь
  ,0x7c, 0x14, 0x14, 0x14, 0x08 // 72 r = р
  ,0x38, 0x44, 0x44, 0x44, 0x20 // 73 s = с
  ,0x04, 0x04, 0x7c, 0x04, 0x04 // 74 t = т
  ,0x84, 0x98, 0x60, 0x18, 0x04 // 75 u = у
  ,0x7c, 0x54, 0x54, 0x28, 0x00 // 76 v = в
  ,0x7c, 0x40, 0x7c, 0x40, 0x7c // 77 w = ш
  ,0x7c, 0x40, 0x7c, 0x40, 0xfc // 78 x = щ
  ,0x7c, 0x50, 0x70, 0x00, 0x7c // 79 y = ы
  ,0x44, 0x54, 0x54, 0x28, 0x00 // 7a z = з
  ,0x04, 0x7c, 0x50, 0x50, 0x20 // 7b { = ъ
  ,0x54, 0x54, 0x54, 0x38, 0x00 // 7c | = э
  ,0x7c, 0x10, 0x38, 0x44, 0x38 // 7d } = ю
  ,0x48, 0x34, 0x14, 0x7c, 0x00 // 7e ← = я
  ,0x0c, 0x10, 0x10, 0x7c, 0x00 // 7f → = ч
};

void LcdCharacter(char character, byte lang)
{
  int i;
  //LcdWrite(LCD_D, 0x00);
  /*if (lang == LANG_RUS) {
   for (i = 0; i < 5; i++)
   {
   LcdWrite(LCD_D, pgm_read_byte(ASCII_ENG + (character - 0x20)*5 + i));
   }
   }*/
  if (lang == LANG_RUS) {
    for (i = 0; i < 5; i++)
    {
      LcdWrite(LCD_D, pgm_read_byte(ASCII_RUS + (character - 0x20)*5 + i));
    }
  } 
  LcdWrite(LCD_D, 0x00);
}

void LcdString(char *characters, byte lang)
{
  while (*characters)
  {
    LcdCharacter(*characters++, lang);
  }
}

void LcdStringXY(int x, int y, char *characters, byte lang)
{
  LcdGotoXY(x, y);
  LcdString(characters, lang);
}

void ConvertNumberToString(long n, char * buf) {
  int i=0;
  int j=0;
  char rev_buf[10];
  if(n==0)
    buf[0] = '0';
  else{
    if(n < 0){
      buf[0] = '-';
      n = -n;
      j++;
    }
    while(n>0 && i <= 10){
      rev_buf[i++] = n % 10;  // n % base
      n /= 10;   // n/= base
    }
    for(; i >0; i--) {
      buf[j] = '0' + rev_buf[i-1];
      j++;
    } 
    buf[j]=0;
  }
}

void LcdPrintNumber(long n)
{
  char * buf = (char*) malloc (5 * sizeof(char));  // prints up to 5 digits  
  int i=0;
  for(i=0; i<5; i++) buf[i]=0; 
  ConvertNumberToString(n, buf);
  i = 0;
  while((i<5) && buf[i]){
    LcdCharacter(buf[i], LANG_RUS);
    i++;
  }
  free(buf);
}

void LcdPrintNumberXY(int x, int y, long n, boolean isAlignedToRight)
{
  char * buf = (char*) malloc (5 * sizeof(char));  // prints up to 5 digits  
  int i=0;
  for(i=0; i<5; i++) buf[i]=0; 
  ConvertNumberToString(n, buf);
  if (! isAlignedToRight) {
    i = 0;
    LcdGotoXY(x, y);
    while((i<5) && buf[i]){
      LcdCharacter(buf[i], LANG_RUS);
      i++;
    }
  } else {
    i = 0;
    //finding last digit
    while((i<5) && buf[i]){
      i++;
    }
    i--;
    int j = 0;
    while(i>=0){
      LcdGotoXY(x - j * 6, y);
      LcdCharacter(buf[i], LANG_RUS);
      i--;
      j++;
    }
  }
  free(buf);
}

void LcdClear(void)
{
  int i, j;
  for (i = 0; i < (LCD_Y/8); i++) {
    LcdGotoXY(0, i);
    for(j = 0; j < LCD_X; j++)
      LcdWrite(LCD_D, 0x00);
  }
}

void LcdInitialise(void)
{
  pinMode(PIN_SCE, OUTPUT);
  pinMode(PIN_RESET, OUTPUT);
  pinMode(PIN_DC, OUTPUT);
  pinMode(PIN_SDIN, OUTPUT);
  pinMode(PIN_SCLK, OUTPUT);
  digitalWrite(PIN_RESET, LOW);
  digitalWrite(PIN_RESET, HIGH);
  LcdWrite(LCD_C, 0x20);
  LcdWrite(LCD_C, 0x0C);
}

void LcdInverseMode(void)
{
  LcdWrite(LCD_C, 0x0D);
}

void LcdNormalMode(void)
{
  LcdWrite(LCD_C, 0x0C);
}



void LcdWrite(byte dc, byte data)
{
  digitalWrite(PIN_DC, dc);
  digitalWrite(PIN_SCE, LOW);
  shiftOut(PIN_SDIN, PIN_SCLK, MSBFIRST, data);
  digitalWrite(PIN_SCE, HIGH);
}

void LcdGotoXY(int x, int y) //moving cursor to desired row/column
{
  if((x < LCD_X) && (x >= 0) && (y < (LCD_Y/8)) && (y >= 0)) {
    LcdWrite( 0, 0x80 | x);  // Column.
    LcdWrite( 0, 0x40 | y);  // Row.
  }
}

void LcdBorder(void)
{
  unsigned char  j;  
  for(j=0; j<LCD_X; j++) // top
  {
    LcdGotoXY (j,0);	
    LcdWrite (1,0x01);
  } 	
  for(j=0; j<LCD_X; j++) //Bottom
  {
    LcdGotoXY (j,5);
    LcdWrite (1,0x80);
  } 	
  for(j=0; j<6; j++) // Right
  {
    LcdGotoXY (LCD_X-1,j);
    LcdWrite (1,0xff);
  } 	
  for(j=0; j<6; j++) // Left
  {
    LcdGotoXY (0,j);
    LcdWrite (1,0xff);
  }
}

//-------MEMORY-------
extern int __bss_end;
extern void *__brkval;

int get_free_memory()
{
  int free_memory;

  if((int)__brkval == 0)
    free_memory = ((int)&free_memory) - ((int)&__bss_end);
  else
    free_memory = ((int)&free_memory) - ((int)__brkval);

  return free_memory;
}
//-------MEMORY-------

//EEPROM BEGIN
word records[4];

void read_records(){
  byte buf[2];
  int i;
  Serial.println("Reading.");
  for(i=0; i<4; i++){
    buf[0] = EEPROM.read(i*2);
    buf[1] = EEPROM.read(i*2+1);
    records[i] = buf[0] + 256 * buf[1];
    Serial.print("records[i] = ");
    Serial.println((int)records[i]);
  }
}

//elitny govnokod
int write_record(word new_record){
  int i;
  word rec_max;
  byte i_max = -1;
  
  if(new_record == 0)
    return(-1);//nothing to add
  
  read_records();
  for(i=0; i<4; i++){
    if (new_record > records[i]) {
      i_max = i;
      break;
    }
  }

  switch(i_max){
    case 0:
      records[3] = records[2];
      records[2] = records[1];
      records[1] = records[0];
      records[0] = new_record;
      break;
    case 1:
      records[3] = records[2];
      records[2] = records[1];
      records[1] = new_record;
      break;
    case 2:
      records[3] = records[2];
      records[2] = new_record;
      break;
    case 3:
      records[3] = new_record;
      break;
    default:
      return(-1);//nothing to add
      break;  
  }
  
  //writing records
  if(i_max>=0) {
    for(i=0; i<4; i++){
      EEPROM.write(i*2,   records[i]&255);
      EEPROM.write(i*2+1, records[i]>>8);
    }
  }

  //return
  return(i_max);
}

byte erase_records(){
  int i;
  for(i=0; i<8; i++)
    EEPROM.write(i, 0);
}


//EEPROM END


#define MODE_MENU           0
#define MODE_SETTINGS       1
#define MODE_GAME           2
#define MODE_RECORDS        3

#define GAME_WAIT           0
#define GAME_FAIL           1
#define GAME_WIN            2
#define GAME_RECORD         3


byte cur_mode = MODE_MENU;
byte redraw = 1;
unsigned long button_1_last = 0;
byte cur_menu = 1;
byte cur_settings = 1;

Bounce button_1 = Bounce();
Bounce button_2 = Bounce();
Bounce button_3 = Bounce();
Bounce button_4 = Bounce();

int op1, op2; //operands
byte sign = 0; // 1 +, 2 -, 3 *, 4 :
int answ1, answ2, answ3, answ4; //answers
int right_answ = 0; //number of right answer
byte game_mode;
word score = 0;
byte answ_time = 5;
unsigned long game_time = 0;
byte sound_state = 1;// 1 = 0N, 0 = OFF

void setup(void)
{
  Serial.begin(9600);
  Serial.println("Let's begin!");
  Serial.print("Memory: ");
  Serial.println(get_free_memory());
  LcdInitialise();
  LcdClear();
  pinMode(BUTTON_1, INPUT);
  pinMode(BUTTON_2, INPUT);
  pinMode(BUTTON_3, INPUT);
  pinMode(BUTTON_4, INPUT);
  button_1.attach(BUTTON_1);
  button_1.interval(50);
  button_2.attach(BUTTON_2);
  button_2.interval(50);
  button_3.attach(BUTTON_3);
  button_3.interval(50);
  button_4.attach(BUTTON_4);
  button_4.interval(50);
  tone(PIN_ALARM, 220, 100);
  randomSeed(analogRead(0));
}

void loop1(void){

  Serial.print(digitalRead(BUTTON_1));
  Serial.print(digitalRead(BUTTON_2));
  Serial.print(digitalRead(BUTTON_3));
  Serial.print(digitalRead(BUTTON_4));
  Serial.print(digitalRead(6));
  Serial.println(digitalRead(7));
  delay(100);

}

void init_variables() {
  op1 = random(1, 10);
  op2 = random(1, 10);
  sign = random(1, 3);
  switch(sign) {
  case 1: // +
    right_answ = op1 + op2; 
    break;
  case 2: // -
    right_answ = op1 - op2; 
    break;
  default:
    break;
  }
  switch(random(1, 5)) {
  case 1: 
    answ1 = right_answ; 
    answ2 = right_answ + random(1, 5); 
    answ3 = right_answ - random(1, 5); 
    answ4 = right_answ + random(1, 5); 
    break;
  case 2: 
    answ2 = right_answ; 
    answ3 = right_answ + random(1, 5); 
    answ4 = right_answ - random(1, 5); 
    answ1 = right_answ + random(1, 5); 
    break;
  case 3: 
    answ3 = right_answ; 
    answ4 = right_answ + random(1, 5); 
    answ1 = right_answ - random(1, 5); 
    answ2 = right_answ + random(1, 5); 
    break;
  case 4: 
    answ4 = right_answ; 
    answ1 = right_answ + random(1, 5); 
    answ2 = right_answ - random(1, 5); 
    answ3 = right_answ + random(1, 5); 
    break;
  default:
    break;
  }
  game_mode = GAME_WAIT;
  answ_time = round(4+2.3*exp(1-score/24));
}

void process_key_pressed(byte key_pressed) {
  if (game_mode == GAME_WAIT) {
    if ( //TODO: HERE WILL BE ARRAY
      (key_pressed == 1 && answ1 == right_answ) ||
      (key_pressed == 2 && answ2 == right_answ) ||
      (key_pressed == 3 && answ3 == right_answ) ||
      (key_pressed == 4 && answ4 == right_answ)
    ){//RIGHT ANSWER
      if (sound_state) tone(PIN_ALARM, 880, 100);
      //game_mode = GAME_WIN;
      init_variables();
      score += 1; 
    } else {
      //TODO: check lives
      if (write_record(score)>=0) {
        if (sound_state) {
          tone(PIN_ALARM, 220);
          delay(200);
          tone(PIN_ALARM, 880);
          delay(200);
          noTone(PIN_ALARM);
        }
        game_mode = GAME_RECORD;
      } else {  
        if (sound_state) tone(PIN_ALARM, 220, 100);
        game_mode = GAME_FAIL;
      }
    }
    LcdClear();
    redraw = 1;
  }// if (game_mode == GAME_WAIT)
}

void loop(void)
{
  //time interactions
  if((cur_mode == MODE_GAME) && (game_mode == GAME_WAIT) && ((millis() - game_time) >= 1000)){
    game_time = millis();
    if (answ_time == 0) {
      if (write_record(score)>=0) {
        if (sound_state) {
          tone(PIN_ALARM, 220);
          delay(200);
          tone(PIN_ALARM, 880);
          delay(200);
          noTone(PIN_ALARM);
        }
        game_mode = GAME_RECORD;
      } else {  
        if (sound_state) tone(PIN_ALARM, 220, 100);
        game_mode = GAME_FAIL;
      }
      LcdClear();
    } else {
      if (sound_state) tone(PIN_ALARM, 440, 10);
      answ_time -= 1;
    }
    redraw = 1;
    //beep
  }
  
  //reaction on buttons here
  if (button_1.update()) {     
    if (button_1.read()==1){ //button down 
      Serial.print("Memory: ");
      Serial.println(get_free_memory());
      Serial.print("Button 1 down at: ");
      Serial.println(millis());
      button_1_last = millis();
      if (cur_mode == MODE_MENU) {
        if (sound_state) tone(PIN_ALARM, 440, 10);
        cur_menu = (cur_menu == 3) ? 1 : cur_menu+1;
        LcdClear();
        redraw = 1;
      } 
      else if (cur_mode == MODE_SETTINGS) {
        if (sound_state) tone(PIN_ALARM, 440, 10);
        cur_settings = (cur_settings == 2) ? 1 : cur_settings+1;
        LcdClear();
        redraw = 1;
      } 
      else if(cur_mode == MODE_GAME) {
        process_key_pressed(1);
      }
    } 
    else { //button up
      Serial.print("Button 1 up at: ");
      Serial.println(millis());
      Serial.print("button_1_last = ");
      Serial.println(button_1_last);
      if((millis() - button_1_last) > 1000) { //press 1 sec
        LcdClear();
        redraw = 1;
      }
      button_1_last = 0;
    }
  }

  if (button_2.update()) {     
    if (button_2.read()==1){ //button down 
      if(cur_mode == MODE_MENU) {  
        if (sound_state) tone(PIN_ALARM, 440, 10);
        if (cur_menu == 1) { //game!!!
          cur_mode = MODE_GAME;
          //init variables
          init_variables();
          score = 0;
          game_time = millis();
        }
        if (cur_menu == 2) { 
          cur_mode = MODE_SETTINGS;
        }
        if (cur_menu == 3) { 
          cur_mode = MODE_RECORDS;
        }
        LcdClear();
        redraw = 1; 
      } 
      else if(cur_mode == MODE_SETTINGS) {  
        if (sound_state) tone(PIN_ALARM, 440, 10);
        if (cur_settings == 1) { 
          sound_state = (sound_state)?0:1;
        }
        if (cur_settings == 2) { //back to menu
          cur_mode = MODE_MENU;
        }
        LcdClear();
        redraw = 1; 
      } 
      else if(cur_mode == MODE_RECORDS) {  
        if (sound_state) tone(PIN_ALARM, 440, 10);
        cur_mode = MODE_MENU;
        LcdClear();
        redraw = 1; 
      } 
      else if(cur_mode == MODE_GAME) {
        //reaction
        process_key_pressed(2);
        if((game_mode == GAME_FAIL) || (game_mode == GAME_RECORD)){
          if (sound_state) tone(PIN_ALARM, 440, 10);
          cur_mode = MODE_MENU;
          LcdClear();
          redraw = 1;
        }
      }
      Serial.print("Memory: ");
      Serial.println(get_free_memory());
      Serial.print("Button 2 pressed at: ");
      Serial.println(millis());
    }
  }
  if (button_3.update()) {     
    if (button_3.read()==1){ //button down 
      if(cur_mode == MODE_GAME) {
        //reaction
        process_key_pressed(3);
      }
      Serial.print("Memory: ");
      Serial.println(get_free_memory());
      Serial.print("Button 3 pressed at: ");
      Serial.println(millis());
    }
  }
  if (button_4.update()) {     
    if (button_4.read()==1){ //button down 
      if(cur_mode == MODE_GAME) {
        //reaction
        process_key_pressed(4);
        if((game_mode == GAME_WIN) || (game_mode == GAME_FAIL)||(game_mode == GAME_RECORD)){//start a new game
          if ((game_mode == GAME_FAIL) || (game_mode == GAME_RECORD)) {
            score = 0;
          }
          game_mode = GAME_WAIT;
          init_variables();
          LcdClear();
          redraw = 1;
        }
      } else if(cur_mode == MODE_RECORDS) {
        if (sound_state) tone(PIN_ALARM, 220, 100);
        erase_records();
        LcdClear();
        redraw = 1;
      }
      Serial.print("Memory: ");
      Serial.println(get_free_memory());
      Serial.print("Button 4 pressed at: ");
      Serial.println(millis());
    } 
    else {
    }
  }

  //drawing
  if ((cur_mode == MODE_MENU) && redraw){
    LcdStringXY(29, 0, "IGRA", LANG_RUS);
    LcdStringXY(3, 1, "VESELYE ^ISLA", LANG_RUS);

    if (cur_menu == 1) LcdStringXY(0, 3, ">", LANG_RUS);
    else LcdStringXY(0, 3, " ", LANG_RUS);
    LcdStringXY(6, 3, "IGRATQ", LANG_RUS);
    if (cur_menu == 1) LcdString("<", LANG_RUS);

    if (cur_menu == 2) LcdStringXY(0, 4, ">", LANG_RUS);
    else LcdStringXY(0, 4, " ", LANG_RUS);
    LcdStringXY(6, 4, "NASTRO_KI", LANG_RUS);
    if (cur_menu == 2) LcdString("<", LANG_RUS);

    if (cur_menu == 3) LcdStringXY(0, 5, ">", LANG_RUS);
    else LcdStringXY(0, 5, " ", LANG_RUS);
    LcdStringXY(6, 5, "REKORDY", LANG_RUS);
    if (cur_menu == 3) LcdString("<", LANG_RUS);

    redraw = 0;
    Serial.print("Memory: ");
    Serial.println(get_free_memory());
  }
  if ((cur_mode == MODE_SETTINGS) && redraw){
    LcdStringXY(17, 0, "NASTRO_KI", LANG_RUS);

    if (cur_settings == 1) LcdStringXY(0, 2, ">", LANG_RUS);
    else LcdStringXY(0, 2, " ", LANG_RUS);
    if(sound_state)
      LcdString("ZVUK: VKL", LANG_RUS);
    else
      LcdString("ZVUK: VYKL", LANG_RUS);

    if (cur_settings == 2) LcdStringXY(0, 3, ">", LANG_RUS);
    else LcdStringXY(0, 3, " ", LANG_RUS);
    LcdString("NAZAD", LANG_RUS);
    redraw = 0;
  } 
  if ((cur_mode == MODE_RECORDS) && redraw){
    LcdStringXY(17, 0, "REKORDY", LANG_RUS);
    read_records();
    LcdStringXY(0, 1, "1: ", LANG_RUS);
    LcdPrintNumber(records[0]);
    LcdStringXY(0, 2, "2: ", LANG_RUS);
    LcdPrintNumber(records[1]);
    LcdStringXY(0, 3, "3: ", LANG_RUS);
    LcdPrintNumber(records[2]);
    LcdStringXY(0, 4, "4: ", LANG_RUS);
    LcdPrintNumber(records[3]);
    LcdStringXY(0, 5, "NAZAD", LANG_RUS);
    LcdStringXY(54, 5, "STER.", LANG_RUS);
    redraw = 0;
  } 
  if ((cur_mode == MODE_GAME) && redraw){
    if (game_mode == GAME_WAIT) {
      LcdGotoXY(0, 0);
      LcdPrintNumber(score);

      LcdStringXY(72, 0, "  ", LANG_RUS);
      LcdPrintNumberXY(78, 0, answ_time, true);

      LcdGotoXY(28, 2);
      LcdPrintNumber(op1);
      if (sign == 1) {
        LcdStringXY(38, 2, "+", LANG_RUS);
      }
      else if (sign == 2) {
        LcdStringXY(38, 2, "-", LANG_RUS);
      }
      LcdGotoXY(48, 2);
      LcdPrintNumber(op2);

      LcdPrintNumberXY(0,  3, answ1, false);
      LcdPrintNumberXY(0,  5, answ2, false);
      LcdPrintNumberXY(78, 3, answ3, true);
      LcdPrintNumberXY(78, 5, answ4, true);

    } 
    else if (game_mode == GAME_FAIL) {
      LcdStringXY(0, 0, "O:", LANG_RUS);
      LcdPrintNumber(score);
      LcdStringXY(32, 0, ":-(", LANG_RUS);
      LcdGotoXY(16, 2);
      LcdPrintNumber(op1);
      if (sign == 1) {
        LcdStringXY(26, 2, "+", LANG_RUS);
      } 
      else if (sign == 2) {
        LcdStringXY(26, 2, "-", LANG_RUS);
      }
      LcdGotoXY(36, 2);
      LcdPrintNumber(op2);
      LcdStringXY(46, 2, "=", LANG_RUS);
      LcdGotoXY(56, 2);
      LcdPrintNumber(right_answ);
      LcdStringXY(30, 4, "EXE?", LANG_RUS);
      LcdStringXY(0, 5, "NET", LANG_RUS);
      LcdStringXY(70, 5, "DA", LANG_RUS);
    } 
    else if (game_mode == GAME_WIN) {
      LcdStringXY(0, 0, "O:", LANG_RUS);
      LcdPrintNumber(score);
      LcdStringXY(32, 0, ":-)", LANG_RUS);
      LcdStringXY(16, 1, "PRAVILQNO", LANG_RUS);
      LcdGotoXY(16, 2);
      LcdPrintNumber(op1);
      if (sign == 1) {
        LcdStringXY(26, 2, "+", LANG_RUS);
      } 
      else if (sign == 2) {
        LcdStringXY(26, 2, "-", LANG_RUS);
      }
      LcdGotoXY(36, 2);
      LcdPrintNumber(op2);
      LcdStringXY(46, 2, "=", LANG_RUS);
      LcdGotoXY(56, 2);
      LcdPrintNumber(right_answ);
      LcdStringXY(30, 4, "EXE?", LANG_RUS);
      LcdStringXY(0, 5, "NET", LANG_RUS);
      LcdStringXY(70, 5, "DA", LANG_RUS);
    }
    else if (game_mode == GAME_RECORD) {
      LcdStringXY(32, 0, ":-)", LANG_RUS);
      LcdStringXY(4, 1, "NOVY_ REKORD!", LANG_RUS);
      LcdGotoXY(38, 2);
      LcdPrintNumber(score);
      LcdStringXY(30, 4, "EXE?", LANG_RUS);
      LcdStringXY(0, 5, "NET", LANG_RUS);
      LcdStringXY(70, 5, "DA", LANG_RUS);
    }
    redraw = 0;
  } 
}
