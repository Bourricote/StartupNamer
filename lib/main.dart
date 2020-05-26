// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Startup Name Generator',
      theme: ThemeData(
        primaryColor: Colors.deepPurple,
      ),
      home: RandomWords(),
    );
  }
}

class RandomWords extends StatefulWidget {
  @override
  RandomWordsState createState() => RandomWordsState();
}

class RandomWordsState extends State<RandomWords> {
  final List<WordPair> _suggestions = <WordPair>[];
  final List<String> _ownSaved = <String>[];
  final List<WordPair> _saved = <WordPair>[];
  final TextStyle _biggerFont = const TextStyle(fontSize: 18.0, color: Colors.deepPurpleAccent);
  final TextStyle _titleStyle = const TextStyle(fontSize: 22.0, color: Colors.deepPurpleAccent, fontWeight: FontWeight.bold);
  final GlobalKey<AnimatedListState> _listKey= GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Startup Name Generator'),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.list), onPressed: _pushSaved),
        ],
      ),
      body: _buildSuggestions(),
    );
  }

  void _pushSaved() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Saved Names'),
            ),
            body: _buildLists(),
            floatingActionButton: FloatingActionButton(
              onPressed: _addCustomElement,
              child: Icon(Icons.add),
              backgroundColor: Colors.deepPurple,
            ),
          );
        }
      )
    );
  }

  Widget _buildLists() {
    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.all(8.0),
        ),
        Text(
          'My custom names',
          style: _titleStyle,
        ),
        Expanded(
          child:
            _buildOwnSaved(),
        ),
         Text(
          'Suggestions I saved',
          style: _titleStyle,
        ),
        Expanded(
          child: _buildSaved(),
        ),
      ],
    );
  }

  Widget _addCustomElement()
  {
    final myController = TextEditingController();
    final _formKey = GlobalKey<FormState>();
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Stack(
              overflow: Overflow.visible,
              children: <Widget>[
                Positioned(
                  right: -40.0,
                  top: -40.0,
                  child: InkResponse(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: CircleAvatar(
                      child: Icon(Icons.close),
                      backgroundColor: Colors.deepPurple,
                    ),
                  ),
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: TextFormField(
                          controller: myController,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: RaisedButton(
                          child: Text('Add'),
                          onPressed: () {
                            if (_formKey.currentState.validate()) {
                              _formKey.currentState.save();
                              _ownSaved.insert(0, myController.text);
                              _listKey.currentState.insertItem(0);
                              Navigator.of(context, rootNavigator: true).pop();
                            }
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }

  Widget _buildOwnSaved() {
    return AnimatedList(
        key: _listKey,
        initialItemCount: _ownSaved.length,
        itemBuilder: (context, index, animation) {
          return _buildItem(_ownSaved[index], animation);
        },
    );
  }

  Widget _buildItem(String item, Animation animation) {
    return SizeTransition(
      sizeFactor: animation,
      child: Card(
        child: ListTile(
          title: Text(
            item,
            style: _biggerFont,
          ),
        ),
      ),
    );
  }

  Widget _buildSaved() {
    return AnimatedList(
      initialItemCount: _saved.length,
      itemBuilder: (context, index, animation) {
        return _buildItem(_saved[index].asPascalCase, animation);
      },
    );
  }

  Widget _buildSuggestions() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemBuilder: (context, i) {
        if (i.isOdd) return Divider();
        final index = i ~/2;
        if (index >= _suggestions.length) {
          _suggestions.addAll(generateWordPairs().take(10));
        }
        return _buildRow(_suggestions[index]);
      }
    );
  }

  Widget _buildRow(WordPair pair) {
    final bool alreadySaved = _saved.contains(pair);
    return ListTile(
      title: Text(
        pair.asPascalCase,
        style: _biggerFont,
      ),
      trailing: Icon(
        alreadySaved ? Icons.favorite : Icons.favorite_border,
        color: alreadySaved ? Colors.deepPurpleAccent : null,
      ),
      onTap: () {
        setState(() {
          if (alreadySaved) {
            _saved.remove(pair);
          } else {
            _saved.add(pair);
          }
        });
      },
    );
  }
}


