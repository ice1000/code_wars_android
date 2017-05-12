///
/// Created by ice1000 on 2017/5/11
///
/// @author ice1000
///

class CodeWarsAPI {
  static getUser({user: String}) =>
      "https://www.codewars.com/api/v1/users/$user";

  static getCompletedKata({user: String}) =>
      "http://www.codewars.com:3000/api/v1/users/$user/code_challenges/completed";
}
