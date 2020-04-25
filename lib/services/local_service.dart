import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:reserve_it_app/models/local.dart';

/*
* Service for the entity Local.
* */
class LocalService {
  //local collection reference
  final CollectionReference LOCAL_COLLECTION =
      Firestore.instance.collection('restaurants');

  /*
  * Gets all the locals from the database
  * */
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

  /*
  * Search locals after a given location
  * and returns them.
  * */
  getLocalsAfterLocation(String city) async {
    QuerySnapshot snapshot = await LOCAL_COLLECTION.getDocuments();
    List<Local> locals = [];
    snapshot.documents.forEach((document) {
      Local local = Local.fromJson(document.data);
      local.id = FieldPath.documentId.toString();
      if(local.address.city == city) {
        locals.add(local);
      }
    });
    return locals;
  }

  /*
  * Filters the locals after the city and attractions. An
  * attraction can be considered also the name of the local,
  * so that the user can search directly a restaurant after
  * its name.
  * */
  getFilteredLocals(List<String> criteria, String city) async {
    List<Local> locals = [];
    List<Local> allLocals = await getLocalsAfterLocation(city);
    for(Local local in allLocals) {
      for( String crit in criteria) {
        if(local.name.contains(crit)) {
          locals.add(local);
          break;
        }
        for(String attraction in local.attractions) {
          if(attraction.contains(crit)) {
            locals.add(local);
            break;
          }
        }
      }
    }
    return locals.toSet().toList();
  }
}
