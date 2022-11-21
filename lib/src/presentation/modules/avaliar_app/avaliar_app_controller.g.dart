// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'avaliar_app_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$AvaliarAppController on _AvaliarAppBase, Store {
  final _$avaliacaoAtom = Atom(name: '_AvaliarAppBase.avaliacao');

  @override
  GrauSatisfacao get avaliacao {
    _$avaliacaoAtom.reportRead();
    return super.avaliacao;
  }

  @override
  set avaliacao(GrauSatisfacao value) {
    _$avaliacaoAtom.reportWrite(value, super.avaliacao, () {
      super.avaliacao = value;
    });
  }

  final _$tipoFeedbackAtom = Atom(name: '_AvaliarAppBase.tipoFeedback');

  @override
  TipoFeedback get tipoFeedback {
    _$tipoFeedbackAtom.reportRead();
    return super.tipoFeedback;
  }

  @override
  set tipoFeedback(TipoFeedback value) {
    _$tipoFeedbackAtom.reportWrite(value, super.tipoFeedback, () {
      super.tipoFeedback = value;
    });
  }

  @override
  String toString() {
    return '''
avaliacao: ${avaliacao},
tipoFeedback: ${tipoFeedback}
    ''';
  }
}
