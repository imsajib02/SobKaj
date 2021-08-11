import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sobkaj/contract/bid_contract.dart';
import 'package:sobkaj/contract/complaint_contact.dart';
import 'package:sobkaj/contract/connectivity_contract.dart';
import 'package:sobkaj/contract/job_contract.dart';
import 'package:sobkaj/contract/review_contract.dart';
import 'package:sobkaj/localization/app_localization.dart';
import 'package:sobkaj/models/bid.dart';
import 'package:sobkaj/models/complaint.dart';
import 'package:sobkaj/models/job.dart';
import 'package:sobkaj/models/payment.dart';
import 'package:sobkaj/models/review.dart';
import 'package:sobkaj/presenter/user_presenter.dart';
import 'package:sobkaj/utils/api_routes.dart';
import 'package:sobkaj/utils/custom_log.dart';
import 'package:sobkaj/utils/custom_trace.dart';
import 'package:sobkaj/utils/my_connectivity_checker.dart';
import 'package:sobkaj/utils/my_overlay_loader.dart';

import 'package:http/http.dart' as http;

import '../utils/constants.dart';

ValueNotifier<Jobs> activeJobs = ValueNotifier(Jobs(list: List()));

class JobPresenter with ChangeNotifier {

  JobContract _jobContract;
  BidContract _bidContract;
  ReviewContract _reviewContract;
  ComplaintContract _complaintContract;
  Connectivity _connectivity;

  MyOverlayLoader _myOverlayLoader;

  JobPresenter(Connectivity connectivity, {JobContract jobContract, BidContract bidContract, ReviewContract reviewContract, ComplaintContract complaintContract}) {

    this._connectivity = connectivity;

    if(jobContract != null) {
      this._jobContract = jobContract;
    }

    if(bidContract != null) {
      this._bidContract = bidContract;
    }

    if(reviewContract != null) {
      this._reviewContract = reviewContract;
    }

    if(complaintContract != null) {
      this._complaintContract = complaintContract;
    }
  }


  Future<void> postJob(BuildContext context, Job job) async {

    if(isConnected.value) {

      _connectivity.onConnected(context);

      _myOverlayLoader = MyOverlayLoader(context);
      Overlay.of(context).insert(_myOverlayLoader.loader);

      var request = http.MultipartRequest("POST", Uri.parse(APIRoute.JOB));

      request.fields['token'] = currentUser.value.accessToken.token;
      request.fields['date'] = job.date;
      request.fields['time'] = job.time;
      request.fields['address'] = job.address;
      request.fields['location'] = job.location;
      request.fields['service_id'] = job.serviceID;
      request.fields['provider_id'] = job.providerID;
      request.fields['phone'] = job.phone;
      request.fields['job_fee'] = job.fee;

      if(job.guestName != null && job.guestName.isNotEmpty) {
        request.fields['guest_name'] = job.guestName;
      }

      request.fields['job_info'] = job.description;
      request.fields['job_title'] = job.title;

      var multipartFile;

      if(job.details != null && job.details.list != null) {

        for(int i=0; i<job.details.list.length; i++) {

          if(job.details.list[i].image != null && job.details.list[i].image.isNotEmpty) {

            multipartFile = await http.MultipartFile.fromPath('images['+ i.toString() +']', job.details.list[i].image);
            request.files.add(multipartFile);
          }
        }
      }

      Map<String, String> headers = {"Accept" : "application/json"};
      request.headers.addAll(headers);

      http.StreamedResponse streamResponse = await request.send();
      final response = await http.Response.fromStream(streamResponse);

      CustomLogger.debug(trace: CustomTrace(StackTrace.current), tag: "Job Post", message: response.body);

      var jsonData = json.decode(response.body);

      _myOverlayLoader.loader.remove();

      if(response.statusCode == 200 || response.statusCode == 201) {

        if(jsonData['status']) {

          Job job = Job.fromJson(jsonData['data']['job']);
          _jobContract.onJobPosted(context, job);
        }
        else {

          _jobContract.onPostFailed(context);
        }
      }
      else {

        _jobContract.onPostFailed(context);
      }
    }
    else {

      _connectivity.onDisconnected(context);
    }
  }


  void myJobs(BuildContext context) {

    if(isConnected.value) {

      _connectivity.onConnected(context);

      var client = http.Client();

      Map<String, dynamic> body = {
        'token': currentUser.value.accessToken.token,
      };

      client.post(

          Uri.encodeFull(APIRoute.ALL_JOB),
          body: body,
          headers: {"Accept" : "application/json"}

      ).then((response) async {

        CustomLogger.debug(trace: CustomTrace(StackTrace.current), tag: "All Job", message: response.body);

        var jsonData = json.decode(response.body);

        if(response.statusCode == 200 || response.statusCode == 201) {

          if(jsonData['status']) {

            Jobs jobs = Jobs.fromJson(jsonData['data']);
            _jobContract.showJobList(jobs.list);
          }
          else {

            _jobContract.onFailedToGetJobs(context, AppLocalization.of(context).getTranslatedValue("failed_to_get_jobs"));
          }
        }
        else {

          _jobContract.onFailedToGetJobs(context, AppLocalization.of(context).getTranslatedValue("failed_to_get_jobs"));
        }

      }).timeout(Duration(seconds: 5), onTimeout: () {

        client.close();
        _connectivity.onTimeout(context);

      }).catchError((error) {

        print(error);
        _jobContract.onFailedToGetJobs(context, AppLocalization.of(context).getTranslatedValue("failed_to_get_jobs"));
      });
    }
    else {

      _connectivity.onDisconnected(context);
    }
  }


  void submitBid(BuildContext context, Bid bid) {

    if(isConnected.value) {

      _connectivity.onConnected(context);

      _myOverlayLoader = MyOverlayLoader(context);

      var client = http.Client();

      Overlay.of(context).insert(_myOverlayLoader.loader);

      Map<String, dynamic> body = {
        'token': currentUser.value.accessToken.token,
        'job_id': bid.jobId,
        'fee': bid.fee,
      };

      if(bid.note != null && bid.note.isNotEmpty) {

        body['description'] = bid.note;
      }

      client.post(

          Uri.encodeFull(APIRoute.JOB_BID),
          body: body,
          headers: {"Accept" : "application/json"}

      ).then((response) async {

        CustomLogger.debug(trace: CustomTrace(StackTrace.current), tag: "Job Bid", message: response.body);

        var jsonData = json.decode(response.body);

        if(response.statusCode == 200 || response.statusCode == 201) {

          if(jsonData['status']) {

            if(jsonData['message'] == Constants.ALREADY_BID) {

              _bidContract.onAlreadyBid(context);
            }
            else {

              _bidContract.onBiddingSuccess(context);
            }
          }
          else {

            _bidContract.onBiddingFailed(context);
          }
        }
        else {

          _bidContract.onBiddingFailed(context);
        }

      }).timeout(Duration(seconds: 5), onTimeout: () {

        client.close();
        _connectivity.onTimeout(context);

      }).whenComplete(() {

        _myOverlayLoader.loader.remove();

      }).catchError((error) {

        print(error);
        _bidContract.onBiddingFailed(context);
      });
    }
    else {

      _connectivity.onDisconnected(context);
    }
  }


  void allBid(BuildContext context, String jobID) {

    if(isConnected.value) {

      _connectivity.onConnected(context);

      var client = http.Client();

      Map<String, dynamic> body = {
        'token': currentUser.value.accessToken.token,
        'job_id': jobID,
      };

      client.post(

          Uri.encodeFull(APIRoute.JOB_ALL_BID),
          body: body,
          headers: {"Accept" : "application/json"}

      ).then((response) async {

        CustomLogger.debug(trace: CustomTrace(StackTrace.current), tag: "All Bid", message: response.body);

        var jsonData = json.decode(response.body);

        if(response.statusCode == 200 || response.statusCode == 201) {

          if(jsonData['status']) {

            if(jsonData['message'] == Constants.NO_BIDS) {

              _bidContract.onNoBids(context);
            }
            else {

              Bids bids = Bids.fromJson(jsonData['data']);
              _bidContract.showAllBid(bids);
            }
          }
          else {

            _bidContract.failedToGetBids(context);
          }
        }
        else {

          _bidContract.failedToGetBids(context);
        }

      }).timeout(Duration(seconds: 5), onTimeout: () {

        client.close();
        _connectivity.onTimeout(context);

      }).catchError((error) {

        print(error);
        _bidContract.failedToGetBids(context);
      });
    }
    else {

      _connectivity.onDisconnected(context);
    }
  }


  void submitReview(BuildContext context, Review review) {

    if(isConnected.value) {

      _connectivity.onConnected(context);

      _myOverlayLoader = MyOverlayLoader(context);

      var client = http.Client();

      Overlay.of(context).insert(_myOverlayLoader.loader);

      client.post(

          Uri.encodeFull(APIRoute.REVIEW),
          body: review.toJson(),
          headers: {"Accept" : "application/json"}

      ).then((response) async {

        CustomLogger.debug(trace: CustomTrace(StackTrace.current), tag: "Submit Review", message: response.body);

        var jsonData = json.decode(response.body);

        if(response.statusCode == 200 || response.statusCode == 201) {

          if(jsonData['status']) {

            if(jsonData['message'] == Constants.ALREADY_REVIEWED) {

              _reviewContract.onReviewPostFailed(context, AppLocalization.of(context).getTranslatedValue("already_reviewed"));
            }
            else {

              Review review = Review.fromJson(jsonData['data']['ratingReview']);
              _reviewContract.onReviewSaved(context, review);
            }
          }
          else {

            _reviewContract.onReviewPostFailed(context, AppLocalization.of(context).getTranslatedValue("review_post_failed"));
          }
        }
        else {

          _reviewContract.onReviewPostFailed(context, AppLocalization.of(context).getTranslatedValue("review_post_failed"));
        }

      }).timeout(Duration(seconds: 5), onTimeout: () {

        client.close();
        _connectivity.onTimeout(context);

      }).whenComplete(() {

        _myOverlayLoader.loader.remove();

      }).catchError((error) {

        print(error);
        _reviewContract.onReviewPostFailed(context, AppLocalization.of(context).getTranslatedValue("review_post_failed"));
      });
    }
    else {

      _connectivity.onDisconnected(context);
    }
  }


  void getSeekerReviews(BuildContext context, String seekerID) {

    if(isConnected.value) {

      _connectivity.onConnected(context);

      var client = http.Client();

      Map<String, dynamic> body = {
        'token': currentUser.value.accessToken.token,
        'id': seekerID,
      };

      client.post(

          Uri.encodeFull(APIRoute.ALL_REVIEW),
          body: body,
          headers: {"Accept" : "application/json"}

      ).then((response) async {

        CustomLogger.debug(trace: CustomTrace(StackTrace.current), tag: "Seeker Reviews", message: response.body);

        var jsonData = json.decode(response.body);

        if(response.statusCode == 200 || response.statusCode == 201) {

          if(jsonData['status']) {

            if(jsonData['message'] == Constants.NO_REVIEW) {

              _reviewContract.showAllReview(Reviews(list: List()));
            }
            else {

              Reviews reviews = Reviews.fromJson(jsonData['data']['ratingReview']);
              _reviewContract.showAllReview(reviews);
            }
          }
          else {

            _reviewContract.failedToGetReviews(context);
          }
        }
        else {

          _reviewContract.failedToGetReviews(context);
        }

      }).timeout(Duration(seconds: 5), onTimeout: () {

        client.close();
        _connectivity.onTimeout(context);

      }).catchError((error) {

        print(error);
        _reviewContract.failedToGetReviews(context);
      });
    }
    else {

      _connectivity.onDisconnected(context);
    }
  }


  void acceptBid(BuildContext context, String bidID, String note) {

    if(isConnected.value) {

      _connectivity.onConnected(context);

      _myOverlayLoader = MyOverlayLoader(context);

      var client = http.Client();

      Overlay.of(context).insert(_myOverlayLoader.loader);

      Map<String, dynamic> body = {
        'token': currentUser.value.accessToken.token,
        'id': bidID,
        'note': note
      };

      client.post(

          Uri.encodeFull(APIRoute.BID_ACCEPT),
          body: body,
          headers: {"Accept" : "application/json"}

      ).then((response) async {

        CustomLogger.debug(trace: CustomTrace(StackTrace.current), tag: "Bid Accept", message: response.body);

        var jsonData = json.decode(response.body);

        if(response.statusCode == 200 || response.statusCode == 201) {

          if(jsonData['status']) {

            Bid bid = Bid.fromJson(jsonData['data']['jobBid']);
            _bidContract.onBidAccepted(context, bid);
          }
          else {

            _bidContract.onBidAcceptFailed(context);
          }
        }
        else {

          _bidContract.onBidAcceptFailed(context);
        }

      }).timeout(Duration(seconds: 5), onTimeout: () {

        client.close();
        _connectivity.onTimeout(context);

      }).whenComplete(() {

        _myOverlayLoader.loader.remove();

      }).catchError((error) {

        print(error);
        _bidContract.onBidAcceptFailed(context);
      });
    }
    else {

      _connectivity.onDisconnected(context);
    }
  }


  void getActiveJobs(BuildContext context) {

    if(isConnected.value) {

      _connectivity.onConnected(context);

      var client = http.Client();

      Map<String, dynamic> body = {
        'token': currentUser.value.accessToken.token,
      };

      client.post(

          Uri.encodeFull(APIRoute.ACTIVE_JOBS),
          body: body,
          headers: {"Accept" : "application/json"}

      ).then((response) async {

        CustomLogger.debug(trace: CustomTrace(StackTrace.current), tag: "Active Nearby Jobs", message: response.body);

        var jsonData = json.decode(response.body);

        if(response.statusCode == 200 || response.statusCode == 201) {

          if(jsonData['status']) {

            Jobs jobs = Jobs.fromJson(jsonData['data']);
            _jobContract.showJobList(jobs.list);
          }
          else {

            _jobContract.onFailedToGetJobs(context, AppLocalization.of(context).getTranslatedValue("failed_to_get_nearby_jobs"));
          }
        }
        else {

          _jobContract.onFailedToGetJobs(context, AppLocalization.of(context).getTranslatedValue("failed_to_get_nearby_jobs"));
        }

      }).timeout(Duration(seconds: 5), onTimeout: () {

        client.close();
        _connectivity.onTimeout(context);

      }).catchError((error) {

        print(error);
        _jobContract.onFailedToGetJobs(context, AppLocalization.of(context).getTranslatedValue("failed_to_get_nearby_jobs"));
      });
    }
    else {

      _connectivity.onDisconnected(context);
    }
  }


  void submitComplaint(BuildContext context, Complaint complaint) {

    if(isConnected.value) {

      _connectivity.onConnected(context);

      _myOverlayLoader = MyOverlayLoader(context);

      var client = http.Client();

      Overlay.of(context).insert(_myOverlayLoader.loader);

      client.post(

          Uri.encodeFull(APIRoute.COMPLAINT),
          body: complaint.toJson(),
          headers: {"Accept" : "application/json"}

      ).then((response) async {

        CustomLogger.debug(trace: CustomTrace(StackTrace.current), tag: "Submit Complaint", message: response.body);

        var jsonData = json.decode(response.body);

        if(response.statusCode == 200 || response.statusCode == 201) {

          if(jsonData['status']) {

            if(jsonData['message'] == Constants.ALREADY_COMPLAINED) {

              _complaintContract.onComplaintPostFailed(context, currentUser.value.roleID == Constants.PROVIDER ? AppLocalization.of(context).getTranslatedValue("already_complained_seeker") :
              AppLocalization.of(context).getTranslatedValue("already_complained_provider"));
            }
            else {

              Complaint complaint = Complaint.fromJson(jsonData['data']['complaint']);

              if(complaint != null && complaint.id != null && complaint.id.isNotEmpty && complaint.message != null && complaint.message.isNotEmpty) {

                _complaintContract.onComplaintSaved(context, complaint);
              }
              else {

                _complaintContract.onComplaintPostFailed(context, AppLocalization.of(context).getTranslatedValue("complaint_post_failed"));
              }
            }
          }
          else {

            _complaintContract.onComplaintPostFailed(context, AppLocalization.of(context).getTranslatedValue("complaint_post_failed"));
          }
        }
        else {

          _complaintContract.onComplaintPostFailed(context, AppLocalization.of(context).getTranslatedValue("complaint_post_failed"));
        }

      }).timeout(Duration(seconds: 5), onTimeout: () {

        client.close();
        _connectivity.onTimeout(context);

      }).whenComplete(() {

        _myOverlayLoader.loader.remove();

      }).catchError((error) {

        print(error);
        _complaintContract.onComplaintPostFailed(context, AppLocalization.of(context).getTranslatedValue("complaint_post_failed"));
      });
    }
    else {

      _connectivity.onDisconnected(context);
    }
  }


  void cancelJob(BuildContext context, String jobId) {

    if(isConnected.value) {

      _connectivity.onConnected(context);

      _myOverlayLoader = MyOverlayLoader(context);

      var client = http.Client();

      Overlay.of(context).insert(_myOverlayLoader.loader);

      Map<String, dynamic> body = {
        'token': currentUser.value.accessToken.token,
        'id': jobId,
        'status': Constants.IS_CANCELLED.toString(),
      };

      client.post(

          Uri.encodeFull(APIRoute.JOB),
          body: body,
          headers: {"Accept" : "application/json"}

      ).then((response) async {

        CustomLogger.debug(trace: CustomTrace(StackTrace.current), tag: "Job Cancel", message: response.body);

        var jsonData = json.decode(response.body);

        if(response.statusCode == 200 || response.statusCode == 201) {

          if(jsonData['status']) {

            Job job = Job.fromJson(jsonData['data']['job']);
            _jobContract.onJobUpdated(context, job);
          }
          else {

            _jobContract.onUpdateFailed(context, AppLocalization.of(context).getTranslatedValue("job_cancel_failed"));
          }
        }
        else {

          _jobContract.onUpdateFailed(context, AppLocalization.of(context).getTranslatedValue("job_cancel_failed"));
        }

      }).timeout(Duration(seconds: 5), onTimeout: () {

        client.close();
        _connectivity.onTimeout(context);

      }).whenComplete(() {

        _myOverlayLoader.loader.remove();

      }).catchError((error) {

        print(error);
        _jobContract.onUpdateFailed(context, AppLocalization.of(context).getTranslatedValue("job_cancel_failed"));
      });
    }
    else {

      _connectivity.onDisconnected(context);
    }
  }


  void completeJob(BuildContext context, String jobId) {

    if(isConnected.value) {

      _connectivity.onConnected(context);

      _myOverlayLoader = MyOverlayLoader(context);

      var client = http.Client();

      Overlay.of(context).insert(_myOverlayLoader.loader);

      Map<String, dynamic> body = {
        'token': currentUser.value.accessToken.token,
        'id': jobId,
        'status': Constants.IS_COMPLETE.toString(),
      };

      client.post(

          Uri.encodeFull(APIRoute.JOB),
          body: body,
          headers: {"Accept" : "application/json"}

      ).then((response) async {

        CustomLogger.debug(trace: CustomTrace(StackTrace.current), tag: "Job Cancel", message: response.body);

        var jsonData = json.decode(response.body);

        if(response.statusCode == 200 || response.statusCode == 201) {

          if(jsonData['status']) {

            Job job = Job.fromJson(jsonData['data']['job']);
            _jobContract.onJobUpdated(context, job);
          }
          else {

            _jobContract.onUpdateFailed(context, AppLocalization.of(context).getTranslatedValue("job_complete_failed"));
          }
        }
        else {

          _jobContract.onUpdateFailed(context, AppLocalization.of(context).getTranslatedValue("job_complete_failed"));
        }

      }).timeout(Duration(seconds: 5), onTimeout: () {

        client.close();
        _connectivity.onTimeout(context);

      }).whenComplete(() {

        _myOverlayLoader.loader.remove();

      }).catchError((error) {

        print(error);
        _jobContract.onUpdateFailed(context, AppLocalization.of(context).getTranslatedValue("job_complete_failed"));
      });
    }
    else {

      _connectivity.onDisconnected(context);
    }
  }


  void confirmJobCompletion(BuildContext context, String jobId, String type, String amount, String note) {

    if(isConnected.value) {

      _connectivity.onConnected(context);

      _myOverlayLoader = MyOverlayLoader(context);

      var client = http.Client();

      Overlay.of(context).insert(_myOverlayLoader.loader);

      Map<String, dynamic> body = {
        'token': currentUser.value.accessToken.token,
        'job_id': jobId,
        'payment_method': type,
        'amount': amount,
        'note': note
      };

      client.post(

          Uri.encodeFull(APIRoute.PAYMENT),
          body: body,
          headers: {"Accept" : "application/json"}

      ).then((response) async {

        CustomLogger.debug(trace: CustomTrace(StackTrace.current), tag: "Job Payment", message: response.body);

        var jsonData = json.decode(response.body);

        if(response.statusCode == 200 || response.statusCode == 201) {

          if(jsonData['status']) {

            Payment payment = Payment.fromJson(jsonData['data']['paymentData']);
            _jobContract.onPaymentConfirm(context, payment);
          }
          else {

            _jobContract.onPaymentConfirmFailed(context, AppLocalization.of(context).getTranslatedValue("payment_confirmation_failed"));
          }
        }
        else {

          _jobContract.onPaymentConfirmFailed(context, AppLocalization.of(context).getTranslatedValue("payment_confirmation_failed"));
        }

      }).timeout(Duration(seconds: 5), onTimeout: () {

        client.close();
        _connectivity.onTimeout(context);

      }).whenComplete(() {

        _myOverlayLoader.loader.remove();

      }).catchError((error) {

        print(error);
        _jobContract.onPaymentConfirmFailed(context, AppLocalization.of(context).getTranslatedValue("payment_confirmation_failed"));
      });
    }
    else {

      _connectivity.onDisconnected(context);
    }
  }


  void myBids(BuildContext context) {

    if(isConnected.value) {

      _connectivity.onConnected(context);

      var client = http.Client();

      Map<String, dynamic> body = {
        'token': currentUser.value.accessToken.token,
      };

      client.post(

          Uri.encodeFull(APIRoute.SEEKER_ALL_BID),
          body: body,
          headers: {"Accept" : "application/json"}

      ).then((response) async {

        CustomLogger.debug(trace: CustomTrace(StackTrace.current), tag: "Seeker All Bid", message: response.body);

        var jsonData = json.decode(response.body);

        if(response.statusCode == 200 || response.statusCode == 201) {

          if(jsonData['status']) {

            Bids bids = Bids.fromJson(jsonData['data']);

            if(bids != null && bids.list != null && bids.list.length > 0) {

              _bidContract.showAllBid(bids);
            }
            else {

              _bidContract.onNoBids(context);
            }
          }
          else {

            _bidContract.failedToGetBids(context);
          }
        }
        else {

          _bidContract.failedToGetBids(context);
        }

      }).timeout(Duration(seconds: 5), onTimeout: () {

        client.close();
        _connectivity.onTimeout(context);

      }).catchError((error) {

        print(error);
        _bidContract.failedToGetBids(context);
      });
    }
    else {

      _connectivity.onDisconnected(context);
    }
  }


  void cancelBid(BuildContext context, String bidId) {

    if(isConnected.value) {

      _connectivity.onConnected(context);

      _myOverlayLoader = MyOverlayLoader(context);

      var client = http.Client();

      Overlay.of(context).insert(_myOverlayLoader.loader);

      Map<String, dynamic> body = {
        'token': currentUser.value.accessToken.token,
        'status': Constants.BID_CANCELLED,
        'id': bidId,
      };

      client.post(

          Uri.encodeFull(APIRoute.CANCEL_BID),
          body: body,
          headers: {"Accept" : "application/json"}

      ).then((response) async {

        CustomLogger.debug(trace: CustomTrace(StackTrace.current), tag: "Bid Cancel", message: response.body);

        var jsonData = json.decode(response.body);

        if(response.statusCode == 200 || response.statusCode == 201) {

          if(jsonData['status']) {

            Bid bid = Bid.fromJson(jsonData['data']['jobBid']);

            if(bid != null && bid.id != null) {

              _bidContract.onBidCancelled(context, bidId);
            }
            else {

              _bidContract.onBidAcceptFailed(context);
            }
          }
          else {

            _bidContract.onBidAcceptFailed(context);
          }
        }
        else {

          _bidContract.onBidAcceptFailed(context);
        }

      }).timeout(Duration(seconds: 5), onTimeout: () {

        client.close();
        _bidContract.onBiddingFailed(context);

      }).whenComplete(() {

        _myOverlayLoader.loader.remove();

      }).catchError((error) {

        print(error);
        _bidContract.onBidAcceptFailed(context);
      });
    }
    else {

      _connectivity.onDisconnected(context);
    }
  }
}