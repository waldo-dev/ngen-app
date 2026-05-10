import 'package:app/src/model/Category.dart';
import 'package:app/src/util/colors.dart';
import 'package:chips_choice/chips_choice.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/core/storage/localstorage_compat.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:country_list/country_list.dart';

class EditProfile extends StatefulWidget {
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final nameController = TextEditingController();
  final LocalStorage storage = new LocalStorage('ngen_app');
  String birthYear = DateTime.now().year.toString();
  late String gender;
  String nationality = 'Chile';
  final List<String> yearList = new List<String>.generate(150, (i) => (DateTime.now().year - i).toString());
  final List<Country> nationalityList = Countries.list;
  static var _categories = <Category>[];
  List<Category> options = _categories;
  List<dynamic> selectedCategories = [];
  bool loading = false;
  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  setCategoryItems() {
    var _categories = [
      Category(id: 1, name: AppLocalizations.of(context)!.categoryHotel, value: "hotel"),
      Category(id: 2, name: AppLocalizations.of(context)!.categoryRestaurant, value: "restaurant"),
      Category(id: 3, name: AppLocalizations.of(context)!.categoryActivities, value: "activities"),
      Category(id: 4, name: AppLocalizations.of(context)!.categoryPark, value: "park"),
      Category(id: 5, name: AppLocalizations.of(context)!.categoryNightActivities, value: "night_activities"),
      Category(id: 6, name: AppLocalizations.of(context)!.categoryChurch, value: "church"),
      Category(id: 7, name: AppLocalizations.of(context)!.categoryMuseums, value: "museums"),
    ];

    setState(() {
      options = _categories;
    });
  }

  void saveCategories(List<dynamic> values) async {
    setState(() {
      selectedCategories = values;
    });
  }

  void saveProfile() async {
    DocumentReference usersReference = FirebaseFirestore.instance.collection('users').doc(auth.currentUser!.uid);
    setState(() {
      loading = true;
    });

    await usersReference.set(
      {'name': nameController.text, 'birthYear': birthYear, 'gender': gender, 'nationality': nationality, 'categories': selectedCategories},
      SetOptions(merge: true),
    );

    setState(() {
      loading = false;
    });
    Navigator.of(context).pop();
  }

  getUserData() async {
    setState(() {
      loading = true;
    });
    var user = await FirebaseFirestore.instance.collection('users').doc(auth.currentUser!.uid).get();
    Map<String, dynamic> data = user.data() as Map<String, dynamic>;
    nameController.text = data['name'];
    setState(() {
      selectedCategories = data['categories'];
      birthYear = data['birthYear'];
      gender = data['gender'];
      nationality = data['nationality'];
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<String> genderList = [
      AppLocalizations.of(context)!.genderMale,
      AppLocalizations.of(context)!.genderFemale,
      AppLocalizations.of(context)!.genderOther
    ];
    gender = AppLocalizations.of(context)!.genderOther;
    setCategoryItems();
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: Text(
          AppLocalizations.of(context)!.titleProfile,
          style: TextStyle(color: AppColors.font_black, fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.white,
        iconTheme: IconThemeData(
          color: AppColors.font_black, //change your color here
        ),
      ),
      body: Padding(
          padding: EdgeInsets.only(top: 10),
          child: SingleChildScrollView(
              child: Wrap(
                  spacing: 40, // to apply margin in the main axis of the wrap
                  runSpacing: 20, // to apply margin in the cross axis of the wrap
                  children: [
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 50.0),
                  child: Row(
                    children: <Widget>[
                      // Padding(
                      //   padding: const EdgeInsets.only(left: 10.0),
                      //   child: CircleAvatar(
                      //       backgroundColor: AppColors.lightgrey,
                      //       child: Icon(MdiIcons.genderFemale)),
                      // ),
                      Expanded(
                        child: TextField(
                          controller: nameController,
                          autofocus: false,
                          cursorColor: AppColors.primary,
                          decoration: InputDecoration(
                              filled: true,
                              fillColor: AppColors.white,
                              prefixIcon: Icon(
                                MdiIcons.accountOutline,
                                color: AppColors.primary,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(color: AppColors.primary, width: 1.0),
                                borderRadius: BorderRadius.circular(100.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(color: AppColors.primary, width: 1.0),
                                borderRadius: BorderRadius.circular(100.0),
                              ),
                              labelText: AppLocalizations.of(context)!.name),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 0.0),
                  child: DropdownButtonFormField(
                    decoration: new InputDecoration(
                      fillColor: AppColors.white,
                      filled: true,
                      labelText: AppLocalizations.of(context)!.userBirthYear,
                      labelStyle: TextStyle(color: AppColors.primary),
                      prefixIcon: Icon(
                        MdiIcons.giftOutline,
                        color: AppColors.primary,
                      ),
                      focusColor: AppColors.white,
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: AppColors.primary, width: 1.0),
                        borderRadius: BorderRadius.circular(100.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: AppColors.primary, width: 1.0),
                        borderRadius: BorderRadius.circular(100.0),
                      ),
                    ),
                    isDense: true,
                    dropdownColor: AppColors.white,
                    value: birthYear,
                    items: yearList
                        .map((String item) => DropdownMenuItem<String>(
                              value: item,
                              child: Text(item),
                            ))
                        .toList(),
                    onChanged: (String? value) => {
                      setState(() {
                        birthYear = value!;
                      })
                    },
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 0.0),
                  child: DropdownButtonFormField(
                    decoration: new InputDecoration(
                      labelText: AppLocalizations.of(context)!.userGender,
                      fillColor: AppColors.white,
                      filled: true,
                      labelStyle: TextStyle(color: AppColors.primary),
                      prefixIcon: Icon(
                        MdiIcons.accountQuestionOutline,
                        color: AppColors.primary,
                      ),
                      focusColor: AppColors.white,
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: AppColors.primary, width: 1.0),
                        borderRadius: BorderRadius.circular(100.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: AppColors.primary, width: 1.0),
                        borderRadius: BorderRadius.circular(100.0),
                      ),
                    ),
                    isDense: true,
                    dropdownColor: AppColors.white,
                    value: gender,
                    items: genderList
                        .map((String item) => DropdownMenuItem<String>(
                              value: item,
                              child: Text(item),
                            ))
                        .toList(),
                    onChanged: (String? value) => {
                      setState(() {
                        gender = value!;
                      })
                    },
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 0.0),
                  child: DropdownButtonFormField(
                    isExpanded: true,
                    decoration: new InputDecoration(
                      labelText: AppLocalizations.of(context)!.userNationality,
                      fillColor: AppColors.white,
                      filled: true,
                      labelStyle: TextStyle(color: AppColors.primary),
                      prefixIcon: Icon(
                        MdiIcons.earth,
                        color: AppColors.primary,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: AppColors.primary, width: 1.0),
                        borderRadius: BorderRadius.circular(100.0),
                      ),
                    ),
                    isDense: true,
                    dropdownColor: AppColors.white,
                    value: nationality,
                    items: nationalityList
                        .map((Country item) => DropdownMenuItem<String>(
                              value: item.name,
                              child: Text(item.name),
                            ))
                        .toList(),
                    onChanged: (String? value) => {
                      setState(() {
                        nationality = value!;
                      })
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(left: 40.0, top: 30),
                  child: Text(
                    AppLocalizations.of(context)!.titleInterest,
                    style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 21),
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 0.0),
                  child: ChipsChoice<dynamic>.multiple(
                    value: selectedCategories,
                    wrapped: true,
                    choiceStyle: C2ChoiceStyle(
                      labelStyle: TextStyle(color: AppColors.primary),
                      borderShape: RoundedRectangleBorder(
                          side: BorderSide(width: 1, color: AppColors.primary), borderRadius: BorderRadius.all(Radius.circular(4))),
                    ),
                    onChanged: (val) {
                      saveCategories(val);
                    },
                    choiceItems: C2Choice.listFrom<String, Category>(
                      source: options,
                      value: (i, v) => v.value,
                      label: (i, v) => v.name,
                    ),
                  ),
                ),
              ]))),
      floatingActionButton: Container(
          width: 50,
          padding: EdgeInsets.zero,
          child: MaterialButton(
            onPressed: () {
              saveProfile();
            },
            elevation: 4,
            splashColor: AppColors.white,
            color: AppColors.primary,
            textColor: AppColors.primary,
            child: loading
                ? CircularProgressIndicator(
                    color: AppColors.white,
                  )
                : Icon(
                    MdiIcons.check,
                    color: AppColors.white,
                    size: 30,
                  ),
            padding: EdgeInsets.all(8),
            shape: CircleBorder(),
          )),
    );
  }
}

