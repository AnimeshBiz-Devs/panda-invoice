import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LineItem {
  String description;
  int quantity;
  double rate;

  LineItem({
    required this.description,
    required this.quantity,
    required this.rate,
  });

  double get total => quantity * rate;
}

class InvoiceState extends ChangeNotifier {
  // Organization Details (Saved to Local Storage)
  String orgName = '';
  String orgEmail = '';
  String orgAddress = '';
  String upiId = '';
  String? logoBase64; // Nullable string to hold the base64 encoded logo image

  // Invoice Details (Reset per session)
  String invoiceNumber =
      'INV-${DateTime.now().year}-${DateTime.now().millisecond.toString().padLeft(3, '0')}';
  DateTime dueDate = DateTime.now().add(const Duration(days: 7));
  String clientName = '';
  String clientEmail = '';
  String projectName = '';

  // Line Items
  List<LineItem> items = [LineItem(description: '', quantity: 1, rate: 0.0)];

  InvoiceState() {
    _loadPreferences();
  }

  double get grandTotal {
    return items.fold(0, (sum, item) => sum + item.total);
  }

  // Actions
  void addLineItem() {
    items.add(LineItem(description: '', quantity: 1, rate: 0.0));
    notifyListeners();
  }

  void removeLineItem(int index) {
    if (items.length > 1) {
      items.removeAt(index);
      notifyListeners();
    }
  }

  void updateLineItem(int index, {String? desc, int? qty, double? rate}) {
    if (desc != null) items[index].description = desc;
    if (qty != null) items[index].quantity = qty;
    if (rate != null) items[index].rate = rate;
    notifyListeners();
  }

  void updateOrg({
    String? name,
    String? email,
    String? address,
    String? upi,
    String? base64Logo,
  }) {
    if (name != null) orgName = name;
    if (email != null) orgEmail = email;
    if (address != null) orgAddress = address;
    if (upi != null) upiId = upi;
    // We intentionally allow nulling out the logo if the user "removes" it by passing an empty string
    if (base64Logo != null) logoBase64 = base64Logo.isEmpty ? null : base64Logo;

    notifyListeners();
    _savePreferences();
  }

  void updateInvoice({
    String? invNum,
    DateTime? date,
    String? cName,
    String? cEmail,
    String? pName,
  }) {
    if (invNum != null) invoiceNumber = invNum;
    if (date != null) dueDate = date;
    if (cName != null) clientName = cName;
    if (cEmail != null) clientEmail = cEmail;
    if (pName != null) projectName = pName;
    notifyListeners();
  }

  // Persistence
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    orgName = prefs.getString('orgName') ?? 'PandaForge Agency';
    orgEmail = prefs.getString('orgEmail') ?? 'hello@pandaforge.com';
    orgAddress = prefs.getString('orgAddress') ?? 'New Delhi, India';
    upiId = prefs.getString('upiId') ?? 'animeshdabral007@oksbi';
    logoBase64 = prefs.getString('logoBase64');
    notifyListeners();
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('orgName', orgName);
    await prefs.setString('orgEmail', orgEmail);
    await prefs.setString('orgAddress', orgAddress);
    await prefs.setString('upiId', upiId);

    if (logoBase64 != null) {
      await prefs.setString('logoBase64', logoBase64!);
    } else {
      await prefs.remove('logoBase64');
    }
  }
}
