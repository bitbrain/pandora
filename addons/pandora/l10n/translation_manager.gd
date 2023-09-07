class_name TranslationManager extends Node

static func translate(string: String) -> String:
    var language: String = TranslationServer.get_tool_locale()
    var translations_path: String = "res://addons/pandora/l10n/%s.po" % language
    var fallback_translations_path: String = "res://addons/pandora/l10n/en.po"
    var translations: Translation = load(translations_path if FileAccess.file_exists(translations_path) else fallback_translations_path)
    return translations.get_message(string)