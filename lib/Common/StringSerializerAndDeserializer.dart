class StringSerializerAndDeserializer 
{

static String StringifyWithHifenSeperatedForHabitNotificationTime({required int hourHand, required int minuteHand, required String habitUid, required bool isNotificationSentForTheDay})
{
  String hourString = hourHand.toString().padLeft(2, '0');
  String minuteString = minuteHand.toString().padLeft(2, '0');
  String notificationSentString = isNotificationSentForTheDay ? '1' : '0';
  return '$hourString*$minuteString*$habitUid*$notificationSentString';
}

static Map<String, dynamic> DeserializeHifenSeperatedStringForHabitNotificationTime({required String hifenSeperatedHabitNotificationString})
{
  List<String> parts = hifenSeperatedHabitNotificationString.split('*');
  if (parts.length != 4) {
    throw FormatException('Invalid format for habit notification time string');
  }

  int hourHand = int.parse(parts[0]);
  int minuteHand = int.parse(parts[1]);
  String habitUid = parts[2];
  bool isNotificationSentForTheDay = parts[3] == '1';

  return {
    'hourHand': hourHand,
    'minuteHand': minuteHand,
    'habitUid': habitUid,
    'isNotificationSentForTheDay': isNotificationSentForTheDay,
  };
}

}