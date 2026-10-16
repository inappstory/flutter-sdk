import 'dart:developer';

/// Maximum number of tags allowed in the list.
const int maxTagsCount = 100;

/// A whole valid tag: one or more unicode letters or marks, ASCII digits, `-`
/// or `_`. Marks (`\p{M}`) are allowed so that a combining sequence such as
/// `e` + U+0301 ("é" in NFD form) is accepted just like its precomposed
/// counterpart U+00E9.
final _allowedTag = RegExp(r'^[\p{L}\p{M}0-9_-]+$', unicode: true);

/// A single allowed tag character. Used only on the slow path to pinpoint the
/// first offending character once a tag has failed [_allowedTag].
final _allowedTagChar = RegExp(r'^[\p{L}\p{M}0-9_-]$', unicode: true);

/// Returns a message describing why [tags] are invalid, or null when they are
/// valid.
///
/// Tags are invalid when the list contains more than [maxTagsCount] tags,
/// or when a tag is empty or contains anything other than unicode letters or
/// marks, digits `0-9`, `-` and `_`.
String? tagsValidationError(List<String> tags) {
  if (tags.length > maxTagsCount) {
    return 'The list must not contain more than $maxTagsCount tags.';
  }

  for (final tag in tags) {
    if (tag.isEmpty) {
      return 'Tag must not be empty.';
    }
    if (_allowedTag.hasMatch(tag)) {
      continue;
    }
    // Slow path: the tag is invalid, so walk it once to name the offender.
    for (final rune in tag.runes) {
      final char = String.fromCharCode(rune);
      if (!_allowedTagChar.hasMatch(char)) {
        final code = rune.toRadixString(16).toUpperCase().padLeft(4, '0');
        return 'Tag "$tag" contains an invalid character "$char" (U+$code). '
            'Allowed characters: unicode letters, digits 0-9, "-" and "_".';
      }
    }
  }

  return null;
}

/// Validates [tags], logging the reason to the console when they are invalid.
///
/// Returns true when the tags are valid and may be used as-is; false when they
/// should be dropped (sent empty).
bool checkTags(List<String> tags) {
  final error = tagsValidationError(tags);
  if (error != null) {
    log(error, name: 'InAppStory.tags', level: 900);
    return false;
  }
  return true;
}

/// Returns [tags] when they pass [checkTags], or an empty list when they do
/// not. Invalid tags are dropped (and logged) so the SDK is used with no tags
/// instead of failing.
List<String> sanitizeTags(List<String> tags) =>
    checkTags(tags) ? tags : const <String>[];
