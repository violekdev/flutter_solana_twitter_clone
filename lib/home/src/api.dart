import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_solana_twitter_clone/home/src/model.dart';
import 'package:flutter_solana_twitter_clone/home/src/model/tweet.dart';
import 'package:solana/dto.dart';
import 'package:solana/encoder.dart';
import 'package:solana/solana.dart';

class Workspace {
  late List<ProgramAccount> programList;
  final programIdPublicKeyStr = solanaTweetJSON.metadata['address'] as String;
  final programIdPublicKey = Ed25519HDPublicKey((solanaTweetJSON.metadata['address'] as String).codeUnits);
  final systemProgramId = Ed25519HDPublicKey.fromBase58(SystemProgram.programId);

  Future<List<TweetModel>> getTweet(SolanaClient solanaClient) async {
    final tweets = <TweetModel>[];
    try {
      programList = await solanaClient.rpcClient.getProgramAccounts(
        programIdPublicKeyStr,
        encoding: Encoding.jsonParsed,
        commitment: Commitment.confirmed,
      );
      debugPrint(programList.toString());

      for (var i = 0; i < programList.length; i++) {
        final account = programList[i];
        debugPrint(account.pubkey);

        final result = await solanaClient.rpcClient
            .getAccountInfo(
              account.pubkey,
              commitment: Commitment.confirmed,
              encoding: Encoding.jsonParsed,
            )
            .value;

        final bytes = (result!.data! as BinaryAccountData).data;
        final decodedTweet = TweetModel.fromBorsh(bytes as Uint8List);
        debugPrint(decodedTweet.author.toString());
        debugPrint(decodedTweet.content);

        tweets.add(decodedTweet);
        // ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return tweets;
  }
}

final solanaTweetJSON = SolanaTweetJSON(
  version: '0.1.0',
  name: 'solana_twitter',
  instructions: [
    {
      'name': 'sendTweet',
      'accounts': [
        AccountMeta(pubKey: Ed25519HDPublicKey('tweet'.codeUnits), isWriteable: true, isSigner: true),
        AccountMeta(pubKey: Ed25519HDPublicKey('author'.codeUnits), isWriteable: true, isSigner: true),
        AccountMeta(pubKey: Ed25519HDPublicKey('systemProgram'.codeUnits), isWriteable: false, isSigner: false),
      ],
      'args': [
        {'name': 'topic', 'type': 'string'},
        {'name': 'content', 'type': 'string'},
      ],
    },
  ],
  accounts: [
    {
      'name': 'Tweet',
      'type': {
        'kind': 'struct',
        'fields': [
          {'name': 'author', 'type': 'publicKey'},
          {'name': 'timestamp', 'type': 'i64'},
          {'name': 'topic', 'type': 'string'},
          {'name': 'content', 'type': 'string'},
        ],
      },
    },
  ],
  errors: [
    {'code': 6000, 'name': 'TopicTooLong', 'msg': 'The provided topic should be 50 characters long maximum.'},
    {'code': 6001, 'name': 'ContentTooLong', 'msg': 'The provided content should be 280 characters long maximum.'},
  ],
  metadata: {'address': 'DTpzL966JaPFA1VfoyF5CNdYkSoKPLDXqJErpuJvjcTK'},
);

final idl = {
  'version': '0.1.0',
  'name': 'solana_twitter',
  'instructions': [
    {
      'name': 'sendTweet',
      'accounts': [
        {'name': 'tweet', 'isMut': true, 'isSigner': true},
        {'name': 'author', 'isMut': true, 'isSigner': true},
        {'name': 'systemProgram', 'isMut': false, 'isSigner': false},
      ],
      'args': [
        {'name': 'topic', 'type': 'string'},
        {'name': 'content', 'type': 'string'},
      ],
    }
  ],
  'accounts': [
    {
      'name': 'Tweet',
      'type': {
        'kind': 'struct',
        'fields': [
          {'name': 'author', 'type': 'publicKey'},
          {'name': 'timestamp', 'type': 'i64'},
          {'name': 'topic', 'type': 'string'},
          {'name': 'content', 'type': 'string'},
        ],
      },
    }
  ],
  'errors': [
    {'code': 6000, 'name': 'TopicTooLong', 'msg': 'The provided topic should be 50 characters long maximum.'},
    {'code': 6001, 'name': 'ContentTooLong', 'msg': 'The provided content should be 280 characters long maximum.'},
  ],
  'metadata': {'address': 'DTpzL966JaPFA1VfoyF5CNdYkSoKPLDXqJErpuJvjcTK'},
};
