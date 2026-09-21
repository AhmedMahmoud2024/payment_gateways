class FawryInputModel {
  final String phoneNumber;
  final String email ;

  FawryInputModel({
    required this.phoneNumber,
     required this.email
     }); 

    String  get cleanPhoneNumber=>phoneNumber.trim().replaceAll('', '');
    String  get cleanEmail =>email.trim().toLowerCase();
  
}