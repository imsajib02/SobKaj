import 'package:google_maps_flutter/google_maps_flutter.dart';

class Constants {

  static final MarkerId jobLocation = MarkerId("jbkjnjl");

  static const int SERVICE_MAX_LENGTH = 10;
  static const int TOP_SEEKER_MAX_LENGTH = 10;
  static const int RECOMMENDED_SERVICE_MAX_LENGTH = 10;
  static const int REVIEW_MAX_LENGTH = 30;

  static const int TAB_1 = 0;
  static const int TAB_2 = 1;
  static const int TAB_3 = 2;
  static const int TAB_4 = 3;
  static const int TAB_5 = 4;

  static const String PROVIDER = "3";
  static const String SEEKER = "4";

  static const String MALE = "1";
  static const String FEMALE = "2";
  static const String OTHER = "3";

  static const String INDIVIDUAL = "1";
  static const String BUSINESS = "2";
  static const String NONE = "0";

  static const String ACTIVE = "1";
  static const String INACTIVE = "2";
  static const String SUSPENDED = "3";
  static const String CLOSED = "4";

  static const int IS_ACTIVE = 1;
  static const int IS_INACTIVE = 2;
  static const int IS_SUSPENDED = 3;
  static const int IS_CANCELLED = 4;
  static const int IS_SCHEDULED = 5;
  static const int IS_COMPLETE = 6;

  static const String TOPIC_ALL = "All";
  static const String TOPIC_PROVIDER = "Provider";
  static const String TOPIC_SEEKER = "Seeker";

  static const String UNAUTHORIZED = "Unauthorized";
  static const String INVALID_USER = "Invalid User";
  static const String INVALID_PHONE_OR_PASSWORD = "Invalid phone or password";
  static const String PHONE_ALREADY_TAKEN = "The phone has already been taken.";
  static const String EMAIL_ALREADY_TAKEN = "The email has already been taken.";
  static const String CURRENT_PASSWORD_DOES_NOT_MATCH = "Current password does not match";
  static const String CONFIRM_PASSWORD_DOES_NOT_MATCH = "The password confirmation does not match.";
  static const String PASSWORD_CHANGED = "Password Changed Successfully";
  static const String ALREADY_BID = "You Already Bidded For this Kaj";
  static const String ALREADY_REVIEWED = "You Give Already Rating For This Job";
  static const String ALREADY_COMPLAINED = "You Already Complaint ...";
  static const String NO_BIDS = "There is no Bid For this Kaj";
  static const String NO_PAYOUT = "There is no Payout For this Seeker";
  static const String NO_REVIEW = "There is no Rating Review For this user";

  static const String SIGN_UP = "0";
  static const String PHONE_VERIFY = "1";
  static const String NEW_PHONE_VERIFY = "2";
  static const String PASSWORD_RESET = "3";

  static const String HAND_CASH = "1";
  static const String MOBILE_BANKING = "2";
  static const String CARD_PAYMENT = "3";
  static const String BANK_PAYMENT = "4";

  static const String NO_COMM = "1";
  static const String FIXED_COMM = "2";
  static const String IND_COMM = "3";

  static const String BID_NOT_ACCEPTED = "1";
  static const String BID_ACCEPTED = "2";
  static const String BID_CANCELLED = "3";
  static const String BID_COMPLETED = "4";

  static const String PAID = "1";
  static const String PARTIALLY_PAID = "2";
  static const String DUE = "3";

  static const String PAID_BY_PROVIDER = "1";
  static const String PAID_BY_SEEKER = "2";

  static const String NEW_JOB_POST = "newjobpostid";
  static const String NEW_BID = "jobbidid";
  static const String BID_ACCEPT = "jobbidaccept";
  static const String JOB_CANCEL = "jobcanceledid";
  static const String JOB_COMPLETE = "jobcompleteid";
  static const String PAYMENT_CONFIRMATION = "paymentconfirmed";
  static const String PAY_COMMISSION = "payadmincommission";

  static const List<String> englishNumeric = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"];
  static const List<String> banglaNumeric = ["০", "১", "২", "৩", "৪", "৫", "৬", "৭", "৮", "৯"];

  static const List<String> paymentTypes = ["Hand Cash", "Mobile Banking", "Card Payment", "Bank"];
  static const List<String> paymentTypeValues = ["1", "2", "3", "4"];
}