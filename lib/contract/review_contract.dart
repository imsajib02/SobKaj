import 'package:flutter/material.dart';
import 'package:sobkaj/models/review.dart';

abstract class ReviewContract {

  void onReviewSaved(BuildContext context, Review review);
  void onReviewPostFailed(BuildContext context, String message);
  void showAllReview(Reviews reviews);
  void failedToGetReviews(BuildContext context);
}