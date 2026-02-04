class CompanyModel {
  final String companyName;
  final String brandName;
  final String cnpj;
  final String address;
  final String phoneNumber1;
  final String? phoneNumber2;
  final int? logoImageId;
  final String pixKey;
  final String depositAgency;
  final String depositAccount;

  CompanyModel({
    required this.companyName,
    required this.brandName,
    required this.cnpj,
    required this.address,
    required this.phoneNumber1,
    this.phoneNumber2,
    this.logoImageId,
    required this.pixKey,
    required this.depositAgency,
    required this.depositAccount,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': 1,
      'company_name': companyName,
      'brand_name': brandName,
      'cnpj': cnpj,
      'address': address,
      'phone_number_1': phoneNumber1,
      'phone_number_2': phoneNumber2,
      'logo_image_id': logoImageId,
      'pix_key': pixKey,
      'deposit_agency': depositAgency,
      'deposit_account': depositAccount,
    };
  }

  factory CompanyModel.fromMap(Map<String, dynamic> map) {
    return CompanyModel(
      companyName: map['company_name'],
      brandName: map['brand_name'],
      cnpj: map['cnpj'],
      address: map['address'],
      phoneNumber1: map['phone_number_1'],
      phoneNumber2: map['phone_number_2'],
      logoImageId: map['logo_image_id'],
      pixKey: map['pix_key'],
      depositAgency: map['deposit_agency'],
      depositAccount: map['deposit_account'],
    );
  }
}
