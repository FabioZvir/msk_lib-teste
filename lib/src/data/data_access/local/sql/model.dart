import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:msk/src/core/utils/utils_db.dart';
import 'package:sqfentity/sqfentity.dart';
import 'package:sqfentity_gen/sqfentity_gen.dart';

part 'model.g.dart';

const registroAtividade = SqfEntityTable(
    tableName: 'RegistroAtividade',
    primaryKeyName: 'id',
    primaryKeyType: PrimaryKeyType.integer_auto_incremental,
    useSoftDeleting: true,
    fields: [
      SqfEntityField('idServer', DbType.integer, defaultValue: -1),
      SqfEntityField('sync', DbType.bool, defaultValue: true),
      SqfEntityField('tabela', DbType.text),
      SqfEntityField('log', DbType.text),
      SqfEntityField('tipo', DbType.integer),
      SqfEntityField('data', DbType.datetime),
      SqfEntityField('codUsu', DbType.integer),
      SqfEntityField('codUsuTimber', DbType.integer),
      SqfEntityField('app', DbType.text),
      SqfEntityField('idDevice', DbType.text),
      SqfEntityField('versao', DbType.integer),
    ]);

const arquivoRegistroAtividade = SqfEntityTable(
    tableName: 'ArquivoRegistroAtividade',
    primaryKeyName: 'id',
    primaryKeyType: PrimaryKeyType.integer_auto_incremental,
    useSoftDeleting: true,
    fields: [
      SqfEntityField('idServer', DbType.integer, defaultValue: -1),
      SqfEntityField('sync', DbType.bool, defaultValue: true),
      SqfEntityField('path', DbType.text),
      SqfEntityField('codUsuTimber', DbType.integer),
      SqfEntityFieldRelationship(
          fieldName: 'registroAtividade_id',
          parentTable: registroAtividade,
          deleteRule: DeleteRule.CASCADE,
          defaultValue: '0'),
    ]);

const seqIdentity =
    SqfEntitySequence(sequenceName: 'identity', maxValue: 9007199254740991);

const feedbackUsuario = SqfEntityTable(
    tableName: 'FeedbackUsuario',
    primaryKeyName: 'id',
    primaryKeyType: PrimaryKeyType.integer_auto_incremental,
    useSoftDeleting: true,
    fields: [
      SqfEntityField('idServer', DbType.integer, defaultValue: -1),
      SqfEntityField('sync', DbType.bool, defaultValue: true),
      SqfEntityField('avaliacao', DbType.integer),
      SqfEntityField('texto', DbType.text),
      SqfEntityField('package', DbType.text),
      SqfEntityField('codUsuTimber', DbType.integer),
      SqfEntityField('tipoFeedback', DbType.integer),
    ]);

const arquivoFeedback = SqfEntityTable(
    tableName: 'ArquivoFeedback',
    primaryKeyName: 'id',
    primaryKeyType: PrimaryKeyType.integer_auto_incremental,
    useSoftDeleting: true,
    fields: [
      SqfEntityField('idServer', DbType.integer, defaultValue: -1),
      SqfEntityField('sync', DbType.bool, defaultValue: true),
      SqfEntityField('url', DbType.text),
      SqfEntityField('path', DbType.text),
      SqfEntityField('codUsuTimber', DbType.integer),
      SqfEntityFieldRelationship(
          fieldName: 'feedbackUsuario_id',
          parentTable: feedbackUsuario,
          deleteRule: DeleteRule.CASCADE,
          defaultValue: '0'),
    ]);

@SqfEntityBuilder(myDbModel)
const myDbModel = SqfEntityModel(
    modelName: 'AppDatabase',
    databaseName: 'AppDatabase.db',
    databaseTables: [
      registroAtividade,
      arquivoRegistroAtividade,
      feedbackUsuario,
      arquivoFeedback
    ],
    preSaveAction: UtilsDB.getPreSaveAction,
    logFunction: UtilsDB.getLogFunction,
    sequences: [seqIdentity],
    bundledDatabasePath: null,
    defaultColumns: const [
      SqfEntityField('lastUpdate', DbType.integer),
      SqfEntityField('uniqueKey', DbType.integer),
      SqfEntityField('codUsu', DbType.integer, defaultValue: -2),
    ]);
