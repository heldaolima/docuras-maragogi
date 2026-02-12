import 'package:docuras_maragogi/app/data/dao/company_dao.dart';
import 'package:docuras_maragogi/app/data/dao/file_dao.dart';
import 'package:docuras_maragogi/app/data/repository/file_repository.dart';
import 'package:docuras_maragogi/app/models/company.dart';
import 'package:docuras_maragogi/app/models/file.dart';

class CompanyRepository {
  final _companyDao = CompanyDao();
  final _fileDao = FileDao();

  /// Saves the company. If [logo] is provided it will be inserted and its id
  /// set to the company. If there was a previous logo, it will be deleted
  /// (both DB record and file on disk) before inserting the new one.
  Future<void> saveCompany(CompanyModel company, FileModel? logo) async {
    final existing = await _companyDao.get();

    if (logo == null) {
      // Simply save if the logo was not changed
      return _companyDao.save(company);
    }

    final logoId = await _fileDao.insert(logo);
    company = CompanyModel( // change logoImageId
      brandName: company.brandName,
      companyName: company.companyName,
      logoImageId: logoId,
      cnpj: company.cnpj,
      address: company.address,
      phoneNumber1: company.phoneNumber1,
      phoneNumber2: company.phoneNumber2,
      pixKey: company.pixKey,
      depositAgency: company.depositAgency,
      depositAccount: company.depositAccount,
    );

    await _companyDao.save(company);

    // Remove old logo if any
    if (existing?.logoImageId != null) {
      final oldFile = await _fileDao.findById(existing!.logoImageId!);
      if (oldFile != null) {
        await FileRepository.deleteFileFromDisk(oldFile);
        await _fileDao.delete(oldFile.id!);
      }
    }
  }

  Future<CompanyModel?> getCompany() => _companyDao.get();

  Future<FileModel?> getCompanyLogoFile() async {
    final company = await getCompany();
    if (company == null || company.logoImageId == null) return null;
    return _fileDao.findById(company.logoImageId!);
  }
}
