/*
"user_id": 8,
"start_time": "2022-03-28T23:43:52.443Z",
"end_time": "2022-03-28T23:45:46.086Z",
"duration": 113,
"pause_duration": 0,
                */
class AppTime {
  int userId;
  String startTime;
  String endTime;
  int duration;
  int pauseDuration;

  AppTime(this.userId, this.startTime, this.endTime, this.duration,
      this.pauseDuration);

  AppTime.fromJson(Map<String, dynamic> json)
      : userId = json['user_id'],
        startTime = json['start_time'],
        endTime = json['end_time'],
        duration = json['duration'],
        pauseDuration = json['pause_duration'];

  Map toJson() => {
        'user_id': userId,
        'start_time': startTime,
        'end_time': endTime,
        'duration': duration,
        'pause_duration': pauseDuration,
      };
}
