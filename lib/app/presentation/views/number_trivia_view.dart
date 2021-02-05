import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../injection_container.dart';
import '../bloc/number_trivia_bloc.dart';
import '../components/wigets.dart';

class NumberTriviaView extends StatelessWidget {
  const NumberTriviaView({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Number Trivia'),
        ),
        body: _buildBody(context));
  }

  BlocProvider<NumberTriviaBloc> _buildBody(BuildContext context) {
    return BlocProvider(
        create: (_) => sl<NumberTriviaBloc>(),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              const SizedBox(height: 10.0),
              BlocBuilder<NumberTriviaBloc, NumberTriviaState>(
                builder: (context, state) {
                  if (state is EmptyNumberTriviaState) {
                    return const MessageDisplay(message: 'Start searching');
                  } else if (state is LoadingNumberTriviaState) {
                    return const LoadingWidget();
                  } else if (state is LoadedNumberTriviaState) {
                    return TriviaDisplay(numberTrivia: state.trivia);
                  } else if (state is ErrorNumberTriviaState) {
                    return MessageDisplay(message: state.message);
                  } else {
                    return Container();
                  }
                },
              ),
              const SizedBox(height: 20),
              const TriviaControls()
            ],
          ),
        ));
  }
}

class TriviaControls extends StatefulWidget {
  const TriviaControls({
    Key key,
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
    BlocProvider.of<NumberTriviaBloc>(context)
        .add(GetTriviaForConcreteNumberEvent(inputString));
  }

  void _dispatchRandom() {
    controller.clear();
    BlocProvider.of<NumberTriviaBloc>(context)
        .add(GetTriviaForRandomNumberEvent());
  }
}
