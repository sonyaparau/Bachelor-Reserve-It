/*
* Class which contains the prefixes
* of more countries for the phone
* number.
* */
class NumberPrefix {
  String flag;
  String name;
  String numberPrefix;

  NumberPrefix(this.flag, this.name, this.numberPrefix);

  static List<NumberPrefix> numberPrefixes() {
    return <NumberPrefix>[
      NumberPrefix('assets/romania_flag.png', 'Romania', '+4'),
      NumberPrefix('assets/germany_flag.png', 'Germany', '+49'),
      NumberPrefix('assets/england_flag.png', 'England', '+44')
    ];
  }
}
