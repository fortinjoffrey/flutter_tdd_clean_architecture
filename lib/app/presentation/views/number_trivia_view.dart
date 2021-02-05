import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';

import '../components/wigets.dart';
import '../state/number_trivia_store.dart';

class NumberTriviaView extends StatefulWidget {
  final NumberTriviaStore numberTriviaStore;

  const NumberTriviaView({
    Key key,
    @required this.numberTriviaStore,
  }) : super(key: key);

  @override
  _NumberTriviaViewState createState() => _NumberTriviaViewState();
}

class _NumberTriviaViewState extends State<NumberTriviaView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  ReactionDisposer _reactionDisposer;

  @override
  void initState() {
    _reactionDisposer = reaction((_) => widget.numberTriviaStore.errorMessage,
        (String message) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(message)));
    });
    super.initState();
  }

  @override
  void dispose() {
    _reactionDisposer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: const Text('Number Trivia'),
        ),
        body: _buildBody(context));
  }

  Widget _buildBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          const SizedBox(height: 10.0),
          Observer(
            builder: (_) {
              switch (widget.numberTriviaStore.state) {
                case StoreState.initial:
                  return const MessageDisplay(message: 'Start searching');
                  break;
                case StoreState.pending:
                  return const LoadingWidget();
                  break;
                case StoreState.complete:
                  return TriviaDisplay(
                      numberTrivia: widget.numberTriviaStore.numberTrivia);
                  break;
                case StoreState.error:
                  return MessageDisplay(
                      message: widget.numberTriviaStore.errorMessage);
                  break;
                default:
                  return Container();
              }
            },
          ),
          const SizedBox(height: 20),
          TriviaControls(numberTriviaStore: widget.numberTriviaStore)
        ],
      ),
    );
  }
}

class TriviaControls extends StatefulWidget {
  final NumberTriviaStore numberTriviaStore;

  const TriviaControls({
    Key key,
    @required this.numberTriviaStore,
  }) : super(key: key);

  @override
  _TriviaControlsState createState() => _TriviaControlsState();
}

class _TriviaControlsState extends State<TriviaControls> {
  final controller = TextEditingController();
  String inputString;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          onSubmitted: (_) {
            _dispatchConcrete();
          },
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Input a number',
          ),
          onChanged: (value) {
            inputString = value;
          },
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: RaisedButton(
                onPressed: _dispatchConcrete,
                color: Theme.of(context).accentColor,
                textTheme: ButtonTextTheme.primary,
                child: const Text('Search'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: RaisedButton(
                onPressed: _dispatchRandom,
                child: const Text('Get random trivia'),
              ),
            ),
          ],
        )
      ],
    );
  }

  void _dispatchConcrete() {
    controller.clear();
    widget.numberTriviaStore.getConcrete(inputString);
  }

  void _dispatchRandom() {
    controller.clear();
    widget.numberTriviaStore.getRandom();
  }
}
