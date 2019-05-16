import 'dart:async';

class ValidationMixin {
  static final _nameRegexMatcher = NameRegexValidator();
  
  final validateName =
      StreamTransformer<String, String>.fromHandlers(handleData: (name, sink) {
    if (_nameRegexMatcher.isValid(name)) {
      sink.add(name);
    } else {
      sink.addError('Only use letters and numbers');
    }
  });
}

class NameRegexValidator extends RegexValidator {
  NameRegexValidator() : super(regexSource: "^[a-zA-Z0-9\\s]*\$");
}

class RegexValidator {
  RegexValidator({this.regexSource});

  final String regexSource;

  bool isValid(String value) {
    try {
      final regex = RegExp(regexSource);
      final matches = regex.allMatches(value);
      for (Match match in matches) {
        if (match.start == 0 && match.end == value.length) {
          return true;
        }
      }
      return false;
    } catch (e) {
      // Invalid regex
      assert(false, e.toString());
      return true;
    }
  }
}
