///
/// Created by ice1000 on 2017/5/11
///
/// @author ice1000
///

import 'dart:convert';
import 'package:http/http.dart';

class CodeWarsAPI {
  static CodeWarsUser getUser({user: String}) {
    get("https://www.codewars.com/api/v1/users/$user").then((val) {
      return new JsonDecoder(null).convert(val.body);
    });
    return null;
  }

  static getCompletedKata({user: String}) =>
      "http://www.codewars.com/api/v1/users/$user/code-challenges/completed";

  static getKata({kata: String}) =>
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
  String name;
  String displayName;
  List<String> skills;
}

class Ranks {
  Rank overall;
  Rank languages;
}

class Rank {
  int rank;
  String name;
  String color;
  int score;
}
