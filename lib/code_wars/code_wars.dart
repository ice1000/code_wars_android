///
/// Created by ice1000 on 2017/5/11
///
/// @author ice1000
///

import 'dart:convert';
import 'package:http/http.dart';

class CodeWarsAPI {
  static CodeWarsUser getUser(String user) {
    get("https://www.codewars.com/api/v1/users/$user").then((val) {
      var json = new JsonDecoder(null)
          .convert(val.body);
      print(val.body);
      var ret = new CodeWarsUser.empty();
      ret.name = json['name'];
      print(ret.name);
      ret.username = json['username'];
//        ..rank = new Ranks(new Rank(
//            json['ranks']['overall']['rank'],
//            json['ranks']['overall']['name'],
//            json['ranks']['overall']['color'],
//            json['ranks']['overall']['score'],
//            'overall'
      return ret;
    });
    return null;
  }

  static getCompletedKata(String user) =>
      "http://www.codewars.com/api/v1/users/$user/code-challenges/completed";

  static getKata(String kata) =>
      "http://www.codewars.com/api/v1/code-challenges/$kata";
}

/*
{
  "username": "some_user",
  "name": "Some Person",
  "honor": 544,
  "clan": "some clan",
  "leaderboardPosition": 134,
  "skills": [
    "haskell",
    "kotlin"
  ],
  "ranks": {
    "overall": {
      "rank": -3,
      "name": "3 kyu",
      "color": "blue",
      "score": 2116
    },
    "languages": {
      "javascript": {
        "rank": -3,
        "name": "3 kyu",
        "color": "blue",
        "score": 1819
      },
      "ruby": {
        "rank": -4,
        "name": "4 kyu",
        "color": "blue",
        "score": 1005
      },
      "coffeescript": {
        "rank": -4,
        "name": "4 kyu",
        "color": "blue",
        "score": 870
      }
    }
  },
  "codeChallenges": {
    "totalAuthored": 3,
    "totalCompleted": 230
  }
}
*/

class CodeWarsUser {
  String username;

  String name;
  String displayName;
  Ranks rank;

  CodeWarsUser.empty() {
    username = "Unknown";
    name = "Unknown";
  }

}

class Ranks {
  Rank overall;
  List<Rank> languages;

  Ranks(this.overall, this.languages);
}

class Rank {
  int rank;
  String name;
  String color;
  String lang;
  int score;

  Rank(this.rank, this.name, this.color, this.score, this.lang);
}

/*{
  "completedCodeChallenges": [
    {
      "id": "514b92a657cdc65150000006",
      "name": "Multiples of 3 and 5",
      "slug": "multiples-of-3-and-5",
      "completedLanguages": [
        "javascript",
        "coffeescript",
        "ruby",
        "javascript",
        "ruby",
        "javascript",
        "ruby",
        "coffeescript",
        "javascript",
        "ruby",
        "coffeescript"
      ]
    }
  ]
}
 */
