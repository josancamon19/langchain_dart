import 'package:meta/meta.dart';

import '../base_language.dart';
import '../schema.dart';

/// LLM wrapper should take in a prompt and return a string.
abstract class BaseLLM extends BaseLanguageModel {
  const BaseLLM();

  /// Return type of LLM.
  String get llmType;

  @visibleForOverriding
  Future<LLMResult> generateInternal({
    required final List<String> prompts,
    final List<String>? stop,
  });

  /// Run the LLM on the given prompt.
  ///
  /// - [prompts] The prompts to pass into the model.
  /// - [stop] Optional list of stop words to use when generating.
  ///
  /// Returns the full LLM output.
  ///
  /// Example:
  /// ```dart
  /// response = openai.generate(['Tell me a joke.']);
  /// ```
  Future<LLMResult> generate({
    required final List<String> prompts,
    final List<String>? stop,
  }) {
    return generateInternal(prompts: prompts, stop: stop);
  }

  @override
  Future<LLMResult> generatePrompt({
    required final List<PromptValue> prompts,
    final List<String>? stop,
  }) {
    final promptStrings =
        prompts.map((final p) => p.toString()).toList(growable: false);
    return generate(prompts: promptStrings, stop: stop);
  }

  /// Run the LLM on the given prompt and input.
  Future<String> call({
    required final String prompt,
    final List<String>? stop,
  }) async {
    final result = await generate(prompts: [prompt], stop: stop);
    return result.generations[0][0].text;
  }

  @override
  Future<String> predict({
    required final String text,
    final List<String>? stop,
  }) {
    final finalStop =
        stop != null ? List<String>.from(stop, growable: false) : null;
    return call(prompt: text, stop: finalStop);
  }

  @override
  Future<BaseMessage> predictMessages({
    required final List<BaseMessage> messages,
    final List<String>? stop,
  }) async {
    final text = getBufferString(messages: messages);
    final finalStop =
        stop != null ? List<String>.from(stop, growable: false) : null;
    final content = await call(prompt: text, stop: finalStop);
    return AIMessage(content: content);
  }

  @override
  String toString() => llmType;
}
