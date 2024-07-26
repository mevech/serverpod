import 'package:intl/intl.dart';
import 'package:serverpod_cli/src/analyzer/code_analysis_collector.dart';
import 'package:serverpod_cli/src/analyzer/models/definitions.dart';
import 'package:serverpod_cli/src/analyzer/models/validation/restrictions/base.dart';
import 'package:serverpod_cli/src/generator/types.dart';
import 'package:source_span/source_span.dart';

class DefaultValueRestriction extends ValueRestriction {
  final String key;
  final SerializableModelDefinition? documentDefinition;

  DefaultValueRestriction(this.key, this.documentDefinition);

  @override
  List<SourceSpanSeverityException> validate(
    String parentNodeName,
    dynamic value,
    SourceSpan? span,
  ) {
    var definition = documentDefinition;
    if (definition is! ClassDefinition) return [];

    var field = definition.findField(parentNodeName);
    if (field == null) return [];

    var defaultValueType = field.type.defaultValueType;
    if (defaultValueType == null) return [];

    switch (defaultValueType) {
      case DefaultValueAllowedType.dateTime:
        return _dateDateValidation(value, span);
      case DefaultValueAllowedType.bool:
        return _booleanValidation(value, span);
      case DefaultValueAllowedType.int:
        return _integerValidation(value, span);
      case DefaultValueAllowedType.double:
        return _doubleValidation(value, span);
      case DefaultValueAllowedType.string:
        return _stringValidation(value, span);
    }
  }

  List<SourceSpanSeverityException> _dateDateValidation(
    dynamic value,
    SourceSpan? span,
  ) {
    if (value is DateTime) return [];

    var errors = <SourceSpanSeverityException>[];

    if (value is! String || value.isEmpty) {
      errors.add(
        SourceSpanSeverityException(
          'The "$key" value must be a valid UTC DateTime String or "now"',
          span,
        ),
      );
      return errors;
    }

    if (value == defaultDateTimeValueNow) return [];

    var format = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";

    DateTime? dateTime = DateFormat(format).tryParseStrict(value);

    if (dateTime == null) {
      errors.add(
        SourceSpanSeverityException(
          'The "$key" value must be a valid UTC ($format) DateTime String or "now"',
          span,
        ),
      );
    }

    return errors;
  }

  List<SourceSpanSeverityException> _booleanValidation(
    dynamic value,
    SourceSpan? span,
  ) {
    if (value is bool) return [];

    var errors = <SourceSpanSeverityException>[];

    if (value is! String ||
        value.isEmpty ||
        (value != defaultBooleanTrue && value != defaultBooleanFalse)) {
      errors.add(
        SourceSpanSeverityException(
          'The "$key" value must be a valid boolean: "true" or "false"',
          span,
        ),
      );
      return errors;
    }

    return errors;
  }

  List<SourceSpanSeverityException> _integerValidation(
    dynamic value,
    SourceSpan? span,
  ) {
    if (value is int) return [];

    var errors = <SourceSpanSeverityException>[];

    if (value is! String || value.isEmpty) {
      errors.add(
        SourceSpanSeverityException(
          'The "$key" value must be a valid integer (e.g., "$key"=10).',
          span,
        ),
      );
      return errors;
    }

    int? parsedValue = int.tryParse(value);
    if (parsedValue == null) {
      errors.add(
        SourceSpanSeverityException(
          'The "$key" value must be a valid integer (e.g., "$key"=10).',
          span,
        ),
      );
    }
    return errors;
  }

  List<SourceSpanSeverityException> _doubleValidation(
    dynamic value,
    SourceSpan? span,
  ) {
    if (value is double) return [];

    var errors = <SourceSpanSeverityException>[];

    if (value is! String || value.isEmpty) {
      errors.add(
        SourceSpanSeverityException(
          'The "$key" value must be a valid double (e.g., "$key"=10.5).',
          span,
        ),
      );
      return errors;
    }

    double? parsedValue = double.tryParse(value);
    if (parsedValue == null) {
      errors.add(
        SourceSpanSeverityException(
          'The "$key" value must be a valid double (e.g., "$key"=10.5).',
          span,
        ),
      );
    }

    return errors;
  }

  List<SourceSpanSeverityException> _stringValidation(
    dynamic value,
    SourceSpan? span,
  ) {
    var errors = <SourceSpanSeverityException>[];

    if (value is! String || value.isEmpty) {
      errors.add(
        SourceSpanSeverityException(
          'The "$key" must be a quoted string (e.g., "$key"=\'This is a string\' or "$key"="This is a string").',
          span,
        ),
      );
      return errors;
    }

    bool validDoubleQuote = RegExp(r'^"(\\.|[^"\\])*"$').hasMatch(value);
    bool validSingleQuote = RegExp(r"^'(\\.|[^'\\])*'$").hasMatch(value);

    if (validDoubleQuote || validSingleQuote) {
      return errors;
    }

    if (value.startsWith('\'') && !validSingleQuote) {
      errors.add(
        SourceSpanSeverityException(
          'For single quoted "$key" string values, single quotes must be escaped or use double quotes (e.g., "$key"=\'This "is" a string\' or "$key"=\'This \\\'is\\\' a string\').',
          span,
        ),
      );
    } else if (value.startsWith('"') && !validDoubleQuote) {
      errors.add(
        SourceSpanSeverityException(
          'For double quoted "$key" string values, double quotes must be escaped or use single quotes (e.g., "$key"="This \'is\' a string" or "$key"="This \\"is\\" a string").',
          span,
        ),
      );
    } else {
      errors.add(
        SourceSpanSeverityException(
          'The "$key" must be a quoted string (e.g., "$key"=\'This is a string\' or "$key"="This is a string").',
          span,
        ),
      );
    }

    return errors;
  }
}
