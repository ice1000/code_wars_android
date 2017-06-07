///
/// Created by ice1000 on 2017/5/11
///
/// @author ice1000
///


class CodeWarsAPI {
  static getUser(String user) => "https://www.codewars.com/api/v1/users/$user";

  static getCompletedKata(String user) =>
      "http://www.codewars.com/api/v1/users/$user/code-challenges/completed";

  static getCompletedKataPaginated(String user, int page) =>
      "http://www.codewars.com/api/v1/users/$user/code-challenges/completed?page=$page";

  static getKata(String kata) =>
      "http://www.codewars.com/api/v1/code-challenges/$kata";

  static getAuthoredChallenge(String user) =>
      "http://www.codewars.com:3000/api/v1/users/$user/code-challenges/authored";

  static getErrorWithReason(String reason) =>
      "{\"success\":false,\"reason\":\"$reason\"}";
}

///
/// represents a user of code wars
/// containing data read from api
///
class CodeWarsUser {
  String username = "";
  String name = "";
  String clan = "";
  int honor = 0;
  int leaderboardPosition = -1;
  int totalAuthored;
  int totalCompleted;
  List<String> skills = const[];
  Rank overall;
  List<Rank> langsRank;

  CodeWarsUser();

  CodeWarsUser.fromJson(Map json) {
    username = json['username'];
    name = json['name']?.replaceAll(new RegExp("[\n\r]"), "") ?? 'Unknown';
    clan = json['clan']?.replaceAll(new RegExp("[\n\r]"), "") ?? '';
    honor = json['honor'];
    leaderboardPosition = json['leaderboardPosition'];
    skills = json['skills'];
    if (null == skills || skills.isEmpty) skills = const[" no skills found "];
    totalAuthored = json['codeChallenges']['totalAuthored'];
    totalCompleted = json['codeChallenges']['totalCompleted'];
    var _overall = json['ranks']['overall'];
    overall = new Rank(_overall['rank'], _overall['name'], _overall['color'],
        _overall['score'], _overall['lang']);
    Map _ranks = json['ranks']['languages'];
    langsRank = _ranks.keys.map((key) =>
    new Rank(_ranks[key]['rank'], _ranks[key]['name'], _ranks[key]['color'],
        _ranks[key]['score'], key)).toList();
  }
}

///
/// represents rank of a single language
///
class Rank {
  int rank;
  String name;
  String color;
  String lang;
  int score;

  Rank(this.rank, this.name, this.color, this.score, this.lang);
}

class KataCompleted {
  String id;
  String name;
  String fullName;
  String slug;
  String completedAt;
  List<String> completedLanguages;

  KataCompleted(this.id, this.name, this.slug, this.completedLanguages, this.completedAt) {
    const maxLen = 25;
    if (null == id) {
      name = "[Deleted Kata]";
      slug = "This kata had been deleted on Code Wars.";
      return;
    }
    if (null == slug) slug = "";
    if (null == name) name = "";
    fullName = name;
    if (name.length >= maxLen) name = name.substring(0, maxLen) + "...";
  }

  @override
  String toString() => """{"id": "$id","name": "$name","slug": "$slug","completedLanguages": ${completedLanguages.map((
      s) => "\"s\"")})},"completedAt": "$completedAt"}""";

  static List<KataCompleted> fromJson(Map json) {
    List<Map> ls = json['data'];
    return ls.map((m) =>
    new KataCompleted(m['id'], m['name'], m['slug'], m['completedLanguages'], m['completedAt'])).toList();
  }
}
