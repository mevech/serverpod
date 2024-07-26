import 'package:serverpod_cli/src/database/extensions.dart';
import 'package:serverpod_service_client/serverpod_service_client.dart';
import 'package:test/test.dart';

void main() {
  group('Given String column definition', () {
    group('with no default value', () {
      ColumnDefinition defaultColumn = ColumnDefinition(
        name: 'stringDefault',
        columnType: ColumnType.text,
        isNullable: false,
        dartType: 'String',
      );

      test(
          'when converting to PostgreSQL SQL code, then it should not have the default value',
          () {
        expect(
          defaultColumn.toPgSqlFragment(),
          '"stringDefault" text NOT NULL',
        );
      });
    });

    group('with "This is a default value" as default value', () {
      ColumnDefinition defaultColumn = ColumnDefinition(
        name: 'stringDefault',
        columnType: ColumnType.text,
        isNullable: false,
        columnDefault: '\'This is a default value\'',
        dartType: 'String',
      );

      test(
          'when converting to PostgreSQL SQL code, then it should have the default value',
          () {
        expect(
          defaultColumn.toPgSqlFragment(),
          '"stringDefault" text NOT NULL DEFAULT \'This is a default value\'',
        );
      });
    });

    group('with "Another default value" as default value', () {
      ColumnDefinition defaultColumn = ColumnDefinition(
        name: 'stringDefault',
        columnType: ColumnType.text,
        isNullable: false,
        columnDefault: '\'Another default value\'',
        dartType: 'String',
      );

      test(
          'when converting to PostgreSQL SQL code, then it should have the default value',
          () {
        expect(
          defaultColumn.toPgSqlFragment(),
          '"stringDefault" text NOT NULL DEFAULT \'Another default value\'',
        );
      });
    });

    group('with nullable column and no default value', () {
      ColumnDefinition defaultColumn = ColumnDefinition(
        name: 'stringDefault',
        columnType: ColumnType.text,
        isNullable: true,
        dartType: 'String',
      );

      test(
          'when converting to PostgreSQL SQL code, then it should be nullable with no default value',
          () {
        expect(
          defaultColumn.toPgSqlFragment(),
          '"stringDefault" text',
        );
      });
    });

    group('with nullable column and "This is a default value" as default value',
        () {
      ColumnDefinition defaultColumn = ColumnDefinition(
        name: 'stringDefault',
        columnType: ColumnType.text,
        isNullable: true,
        columnDefault: '\'This is a default value\'',
        dartType: 'String',
      );

      test(
          'when converting to PostgreSQL SQL code, then it should be nullable with the default value',
          () {
        expect(
          defaultColumn.toPgSqlFragment(),
          '"stringDefault" text DEFAULT \'This is a default value\'',
        );
      });
    });

    group('with nullable column and "Another default value" as default value',
        () {
      ColumnDefinition defaultColumn = ColumnDefinition(
        name: 'stringDefault',
        columnType: ColumnType.text,
        isNullable: true,
        columnDefault: '\'Another default value\'',
        dartType: 'String',
      );

      test(
          'when converting to PostgreSQL SQL code, then it should be nullable with the default value',
          () {
        expect(
          defaultColumn.toPgSqlFragment(),
          '"stringDefault" text DEFAULT \'Another default value\'',
        );
      });
    });
  });
}
