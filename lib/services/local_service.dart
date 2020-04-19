import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:reserve_it_app/models/local.dart';

/*
* Service for the entity Local.
* */
class LocalService {
  //local collection reference
  final CollectionReference LOCAL_COLLECTION =
      Firestore.instance.collection('restaurants');

  getLocals() async {
    QuerySnapshot snapshot = await LOCAL_COLLECTION.getDocuments();
    List<Local> locals = [];

    snapshot.documents.forEach((document) {
      Local local = Local.fromJson(document.data);
      local.id = FieldPath.documentId.toString();
      locals.add(local);
    });
    return locals;
  }

  getFilteredLocals(List<String> criteria) async {
    List<Local> locals = [];
    for (String c in criteria) {
      QuerySnapshot query = await LOCAL_COLLECTION
          .where('attractions', arrayContains: c)
          .getDocuments();
      query.documents.forEach((document) {
        Local local = Local.fromJson(document.data);
        local.id = FieldPath.documentId.toString();
        locals.add(local);
      });
    }
    return locals.toSet().toList();
  }
}
