#define fan 2
#define bulb 3

void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600);
  pinMode(fan, OUTPUT);
  pinMode(bulb, OUTPUT);
  digitalWrite(bulb, HIGH);
  digitalWrite(fan, HIGH);
}

void loop() {
  // put your main code here, to run repeatedly:

  if(Serial.available() == 1)
  {
    String val = Serial.readString();
    val.trim();
    Serial.println(val);
    if(val == "fan on")
    {
      digitalWrite(fan, LOW);
    }
    else if(val == "fan off")
    {
      digitalWrite(fan, HIGH);
    }
    else if(val == "bulb on")
    {
      digitalWrite(bulb, LOW);
    }
    else if(val == "bulb off")
    {
      digitalWrite(bulb, HIGH);
    }
    else if(val == "all on")
    {
      digitalWrite(fan, LOW);
      digitalWrite(bulb, LOW);
    }
    else if(val == "all off")
    {
      digitalWrite(bulb, HIGH);
      digitalWrite(fan, HIGH);
    }
    else {
      Serial.println("Recognition failed");
     }
  }
}