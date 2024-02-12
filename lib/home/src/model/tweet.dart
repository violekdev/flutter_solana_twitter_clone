import 'package:borsh_annotation/borsh_annotation.dart';
import 'package:solana/solana.dart';
part 'tweet.g.dart';

@BorshSerializable()
class TweetModel with _$TweetModel {
  factory TweetModel({
    @BU64() required BigInt deterministicId,
    @BPublicKey() required Ed25519HDPublicKey author,
    @BU64() required BigInt timestamp,
    @BString() required String topic,
    @BString() required String content,
    @BPublicKey() required Ed25519HDPublicKey owner,
  }) = _TweetModel;
  const TweetModel._();
  factory TweetModel.fromBorsh(Uint8List data) => _$TweetModelFromBorsh(data);
}
