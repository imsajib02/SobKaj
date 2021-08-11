import 'package:flutter/material.dart';
import 'package:sobkaj/models/bid.dart';

abstract class BidContract {

  void onBiddingSuccess(BuildContext context);
  void onBiddingFailed(BuildContext context);
  void onAlreadyBid(BuildContext context);
  void showAllBid(Bids bids);
  void failedToGetBids(BuildContext context);
  void onNoBids(BuildContext context);
  void onBidAccepted(BuildContext context, Bid bid);
  void onBidAcceptFailed(BuildContext context);
  void onBidCancelled(BuildContext context, String bidId);
}