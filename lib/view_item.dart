import 'package:cached_network_image/cached_network_image.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'db_helper.dart';
import 'package:sleek_button/sleek_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'create_account_signin.dart';
import 'package:intl/intl.dart';
import 'search.dart';

class ViewItem extends StatefulWidget {
  final buCode;
  final tenantCode;
  final prodId;
  final productUom;
  final unitOfMeasure;
  final price;
  final globalID;

  ViewItem({Key key, @required this.buCode, this.tenantCode,this.prodId,this.productUom, this.unitOfMeasure, this.price, this.globalID}) : super(key: key);
  @override
  _ViewItem createState() => _ViewItem();
}

class _ViewItem extends State<ViewItem>{
  final db = RapidA();
  final oCcy = new NumberFormat("#,##0.00", "en_US");
  final itemCount = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  List loadItemData;
  List loadSuggestion;
  var amountPerGram = TextEditingController();
  var totalPerGram  = TextEditingController();
  var isLoading = true;
  int _counter = 1;
  int defaultGram = 100;
  double gramInput = 0.00;
  double apg = 0.00;
  double totalAmount = 0.00;

  String uomId,uomPrice, measurement;
  String choiceUomIdDrinks,choiceIdDrinks,choicePriceDrinks;
  String choiceUomIdFries,choiceIdFries,choicePriceFries;
  String choiceUomIdSides,choiceIdSides,choicePriceSides;
  String uniOfMeasure;
  String suggestionIdFlavor, productSuggestionIdFlavor, suggestionPriceFlavor;
  String suggestionIdWoc, productSuggestionIdWoc, suggestionPriceWoc;
  String suggestionIdTos, productSuggestionIdTos, suggestionPriceTos;
  String suggestionIdTon, productSuggestionIdTon, suggestionPriceTon;
  String suggestionIdTops, productSuggestionIdTops, suggestionPriceTops;
  String suggestionIdCoi, productSuggestionIdCoi, suggestionPriceCoi;
  String suggestionIdCoslfm, productSuggestionIdCoslfm, suggestionPriceCoslfm;
  String suggestionIdSink, productSuggestionIdSink, suggestionPriceSink;
  String suggestionIdBcf, productSuggestionIdBcf, suggestionPriceBcf;
  String suggestionIdCc, productSuggestionIdCc, suggestionPriceCc;
  String suggestionIdCom, productSuggestionIdCom, suggestionPriceCom;
  String suggestionIdCoft, productSuggestionIdCoft, suggestionPriceCoft;
  String suggestionIdCymf, productSuggestionIdCymf, suggestionPriceCymf;
  String suggestionIdTomb, productSuggestionIdTomb, suggestionPriceTomb;
  String suggestionIdCosv, productSuggestionIdCosv, suggestionPriceCosv;
  String suggestionIdTop, productSuggestionIdTop, suggestionPriceTop;
  String suggestionIdTocw, productSuggestionIdTocw, suggestionPriceTocw;
  String suggestionIdNameless, productSuggestionIdNameless, suggestionPriceNameless;
  String variation;

  List<String> selectedSideOnPrice = [];
  List<String> selectedSideItems = [];
  List<String> selectedSideItemsUom = [];
  List<String> selectedSideSides = [];
  List<String> selectedSideDessert = [];
  List<String> selectedSideDrinks = [];

  int choiceDrinksGroupValue;
  int choiceFriesGroupValue;
  int choiceSidesGroupValue;
  int uomDataGroupValue;
  int flavorDataGroupValue;
  int suggestionFlavorDataGroupValue;
  int suggestionWocDataGroupValue;
  int suggestionTosDataGroupValue;
  int suggestionTonDataGroupValue;
  int suggestionTopsDataGroupValue;
  int suggestionCoiDataGroupValue;
  int suggestionCoslfmDataGroupValue;
  int suggestionSinkDataGroupValue;
  int suggestionBcfDataGroupValue;
  int suggestionCcDataGroupValue;
  int suggestionComDataGroupValue;
  int suggestionCoftDataGroupValue;
  int suggestionCymfDataGroupValue;
  int suggestionTombDataGroupValue;
  int suggestionCosvDataGroupValue;
  int suggestionTopDataGroupValue;
  int suggestionTocwDataGroupValue;
  int suggestionNamelessDataGroupValue;

  List<int> array1 =  [0, 1, 1];
  List<int> array2 =  [0, 1, 2];
  List<int> array3 =  [0, 0, 1];


  List addonSidesData;
  List addonDessertData;
  List addonDrinksData;
  List choicesDrinksData;
  List choicesFriesData;
  List choicesSidesData;
  List uomData;
  List suggestionFlavorData;
  List suggestionWocData;
  List suggestionTosData;
  List suggestionTonData;
  List suggestionTopsData;
  List suggestionCoiData;
  List suggestionCoslfmData;
  List suggestionSinkData;
  List suggestionBcfData;
  List suggestionCcData;
  List suggestionComData;
  List suggestionCoftData;
  List suggestionCymfData;
  List suggestionTombData;
  List suggestionCosvData;
  List suggestionTopData;
  List suggestionTocwData;
  List suggestionNamelessData;

  bool addonSidesDataVisible;
  bool addonDessertDataVisible;
  bool addonDrinksDataVisible;
  bool choicesDrinksVisible;
  bool choicesFriesVisible;
  bool choicesSidesVisible;
  bool uomDataVisible;
  bool flavorDataVisible;
  bool suggestionFlavorDataVisible;
  bool suggestionWocDataVisible;
  bool suggestionTosDataVisible;
  bool suggestionTonDataVisible;
  bool suggestionTopsDataVisible;
  bool suggestionCoiDataVisible;
  bool suggestionCoslfmDataVisible;
  bool suggestionSinkDataVisible;
  bool suggestionBcfDataVisible;
  bool suggestionCcDataVisible;
  bool suggestionComDataVisible;
  bool suggestionCoftDataVisible;
  bool suggestionCymfDataVisible;
  bool suggestionTombDataVisible;
  bool suggestionCosvDataVisible;
  bool suggestionTopDataVisible;
  bool suggestionTocwDataVisible;
  bool suggestionNamelessDataVisible;
  bool grams;
  bool price;

  var index = 0;
  String sides;

  Future onRefresh() async {

    loadStore();
    // getSuggestion();
  }

  Future loadStore() async {

    addonSidesDataVisible       = true;
    addonDessertDataVisible     = true;
    addonDrinksDataVisible      = true;
    choicesDrinksVisible        = true;
    choicesFriesVisible         = true;
    choicesSidesVisible         = true;
    uomDataVisible              = true;
    flavorDataVisible           = true;
    suggestionFlavorDataVisible = true;
    suggestionWocDataVisible    = true;
    suggestionTosDataVisible    = true;
    suggestionTonDataVisible    = true;
    suggestionTopsDataVisible   = true;
    suggestionCoiDataVisible    = true;
    suggestionCoslfmDataVisible = true;
    suggestionSinkDataVisible   = true;
    suggestionBcfDataVisible    = true;
    suggestionCcDataVisible     = true;
    suggestionComDataVisible    = true;
    suggestionCoftDataVisible   = true;
    suggestionCymfDataVisible   = true;
    suggestionTombDataVisible   = true;
    suggestionCosvDataVisible   = true;
    suggestionTopDataVisible    = true;
    suggestionTocwDataVisible    = true;
    suggestionNamelessDataVisible    = true;
    grams                       = false;
    price                       = true;

    uomId = widget.productUom;
    uomPrice = widget.price;
    setState(() {
      isLoading = true;
    });


    var res = await db.getItemDataCi(widget.prodId, widget.productUom);
    if (!mounted) return;
     setState(() {
      loadItemData = res['user_details'];
      isLoading = false;
      itemCount.text          = "1";
      addonSidesData          = loadItemData[1]['addon_sides_data'];
      addonDessertData        = loadItemData[2]['addon_dessert_data'];
      addonDrinksData         = loadItemData[3]['addon_drinks_data'];
      choicesDrinksData       = loadItemData[4]['choices_drinks_data'];
      choicesFriesData        = loadItemData[5]['choices_fries_data'];
      choicesSidesData        = loadItemData[6]['choices_sides_data'];
      uomData                 = loadItemData[7]['uom_data'];
      suggestionFlavorData    = loadItemData[8]['suggestion_flavor_data'];
      suggestionWocData       = loadItemData[9]['suggestion_woc_data'];
      suggestionTosData       = loadItemData[10]['suggestion_tos_data'];
      suggestionTonData       = loadItemData[11]['suggestion_ton_data'];
      suggestionTopsData      = loadItemData[12]['suggestion_tops_data'];
      suggestionCoiData       = loadItemData[13]['suggestion_coi_data'];
      suggestionCoslfmData    = loadItemData[14]['suggestion_coslfm_data'];
      suggestionSinkData      = loadItemData[15]['suggestion_sink_data'];
      suggestionBcfData       = loadItemData[16]['suggestion_bcf_data'];
      suggestionCcData        = loadItemData[17]['suggestion_cc_data'];
      suggestionComData       = loadItemData[18]['suggestion_com_data'];
      suggestionCoftData      = loadItemData[19]['suggestion_coft_data'];
      suggestionCymfData      = loadItemData[20]['suggestion_cymf_data'];
      suggestionTombData      = loadItemData[21]['suggestion_tomb_data'];
      suggestionCosvData      = loadItemData[22]['suggestion_cosv_data'];
      suggestionTopData       = loadItemData[23]['suggestion_top_data'];
      suggestionTocwData      = loadItemData[24]['suggestion_tocw_data'];
      suggestionNamelessData  = loadItemData[25]['suggestion_nameless_data'];

      apg = oCcy.parse(loadItemData[0]['price_per_gram']);
      print(apg);
      totalAmount = apg * defaultGram;
      totalPerGram.text = oCcy.format(totalAmount).toString();

      // print(flavorData);
      print(suggestionTopData);

      // sides = loadItemData[index1]['addon_sides'];

      if(addonSidesData.toString() == '[[]]') {
        addonSidesDataVisible = false;
      }
      if(addonDessertData.toString() == '[[]]') {
        addonDessertDataVisible = false;
      }
      if(addonDrinksData.toString() == '[[]]') {
        addonDrinksDataVisible = false;
      }

      if(choicesDrinksData.toString() == '[[]]') {
        choicesDrinksVisible = false;
      } else {
        for(int q = 0;q<choicesDrinksData.length;q++) {
          if (choicesDrinksData[q]['default'] == '1') {
              choiceDrinksGroupValue = q;
              choiceUomIdDrinks = choicesDrinksData[q]['uom_id'];
              choiceIdDrinks = choicesDrinksData[q]['sub_productid'];
              choicePriceDrinks = choicesDrinksData[q]['addon_price'];
              break;
          }
        }
      }

      if(choicesFriesData.toString() == '[[]]') {
        choicesFriesVisible = false;
      } else {
        for(int q = 0;q<choicesFriesData.length;q++) {
          if (choicesFriesData[q]['default'] == '1') {
            choiceFriesGroupValue = q;
            choiceUomIdFries = choicesFriesData[q]['uom_id'];
            choiceIdFries = choicesFriesData[q]['sub_productid'];
            choicePriceFries = choicesFriesData[q]['addon_price'];
            break;
          }
        }
      }

      if(choicesSidesData.toString() == '[[]]') {
        choicesSidesVisible = false;
      } else {
        for(int i = 0;i<choicesSidesData.length;i++) {
          if (choicesSidesData[i]['default'] == '1') {
            choiceSidesGroupValue = i;
            choiceUomIdSides = choicesSidesData[i]['uom_id'];
            choiceIdSides = choicesSidesData[i]['sub_productid'];
            choicePriceSides = choicesSidesData[i]['addon_price'];
            break;
          }
        }
      }

      if(uomData.toString() == '[[]]' || uomData.length == 1) {
        uomDataVisible = false;
      } else {
        for(int q = 0;q<uomData.length;q++) {
          if (uomData[q]['default'] == '1') {
            uomDataGroupValue = q;
            uomId = uomData[q]['uom_id'];
            break;
          }
        }
      }

      if(suggestionFlavorData.toString() == '[[]]') {
        suggestionFlavorDataVisible = false;
      } else {
        for(int q = 0;q<suggestionFlavorData.length;q++) {
          if (suggestionFlavorData[q]['default'] == '1') {
            suggestionFlavorDataGroupValue = q;
            suggestionIdFlavor = suggestionFlavorData[q]['suggestion_id'];
            productSuggestionIdFlavor = suggestionFlavorData[q]['prod_suggestion_id'];
            suggestionPriceFlavor = suggestionFlavorData[q]['price'];
            print('ang suggestion id kay $suggestionFlavorDataGroupValue');
            break;
          }
        }
      }

      if(suggestionWocData.toString() == '[[]]') {
        suggestionWocDataVisible = false;
      } else {
        for(int q = 0;q<suggestionWocData.length;q++) {
          if (suggestionWocData[q]['default'] == '1') {
            suggestionWocDataGroupValue = q;
            suggestionIdWoc = suggestionWocData[q]['suggestion_id'];
            productSuggestionIdWoc = suggestionWocData[q]['prod_suggestion_id'];
            suggestionPriceWoc = suggestionWocData[q]['price'];
            // print('ang Woc id kay $suggestionWocDataGroupValue');
            break;
          }
        }
      }

      if(suggestionTosData.toString() == '[[]]') {
        suggestionTosDataVisible = false;
      } else {
        for(int q = 0;q<suggestionTosData.length;q++) {
          if (suggestionTosData[q]['default'] == '1') {
            suggestionTosDataGroupValue = q;
            suggestionIdTos = suggestionTosData[q]['suggestion_id'];
            productSuggestionIdTos = suggestionTosData[q]['prod_suggestion_id'];
            suggestionPriceTos = suggestionTosData[q]['price'];
            // print('ang Woc id kay $suggestionTosDataGroupValue');
            break;
          }
        }
      }

      if(suggestionTonData.toString() == '[[]]') {
        suggestionTonDataVisible = false;
      } else {
        for(int q = 0;q<suggestionTonData.length;q++) {
          if (suggestionTonData[q]['default'] == '1') {
            suggestionTonDataGroupValue = q;
            suggestionIdTon = suggestionTonData[q]['suggestion_id'];
            productSuggestionIdTon = suggestionTonData[q]['prod_suggestion_id'];
            suggestionPriceTon = suggestionTonData[q]['price'];
            // print('ang Woc id kay $suggestionTonDataGroupValue');
            break;
          }
        }
      }

      if(suggestionTopsData.toString() == '[[]]') {
        suggestionTopsDataVisible = false;
      } else {
        for(int q = 0;q<suggestionTopsData.length;q++) {
          if (suggestionTopsData[q]['default'] == '1') {
            suggestionTopsDataGroupValue = q;
            suggestionIdTops = suggestionTopsData[q]['suggestion_id'];
            productSuggestionIdTops = suggestionTopsData[q]['prod_suggestion_id'];
            suggestionPriceTops = suggestionTopsData[q]['price'];
            // print('ang Woc id kay $suggestionTopsDataGroupValue');
            break;
          }
        }
      }

      if(suggestionCoiData.toString() == '[[]]') {
        suggestionCoiDataVisible = false;
      } else {
        for(int q = 0;q<suggestionCoiData.length;q++) {
          if (suggestionCoiData[q]['default'] == '1') {
            suggestionCoiDataGroupValue = q;
            suggestionIdCoi = suggestionCoiData[q]['suggestion_id'];
            productSuggestionIdCoi = suggestionCoiData[q]['prod_suggestion_id'];
            suggestionPriceCoi = suggestionCoiData[q]['price'];
            // print('ang Woc id kay $suggestionCoiDataGroupValue');
            break;
          }
        }
      }

      if(suggestionCoslfmData.toString() == '[[]]') {
        suggestionCoslfmDataVisible = false;
      } else {
        for(int q = 0;q<suggestionCoslfmData.length;q++) {
          if (suggestionCoslfmData[q]['default'] == '1') {
            suggestionCoslfmDataGroupValue = q;
            suggestionIdCoslfm = suggestionCoslfmData[q]['suggestion_id'];
            productSuggestionIdCoslfm = suggestionCoslfmData[q]['prod_suggestion_id'];
            suggestionPriceCoslfm = suggestionCoslfmData[q]['price'];
            // print('ang Woc id kay $suggestionCoslfmDataGroupValue');
            break;
          }
        }
      }

      if(suggestionSinkData.toString() == '[[]]') {
        suggestionSinkDataVisible = false;
      } else {
        for(int q = 0;q<suggestionSinkData.length;q++) {
          if (suggestionSinkData[q]['default'] == '1') {
            suggestionSinkDataGroupValue = q;
            suggestionIdSink = suggestionSinkData[q]['suggestion_id'];
            productSuggestionIdSink = suggestionSinkData[q]['prod_suggestion_id'];
            suggestionPriceSink = suggestionSinkData[q]['price'];
            // print('ang Woc id kay $suggestionSinkDataGroupValue');
            break;
          }
        }
      }

      if(suggestionBcfData.toString() == '[[]]') {
        suggestionBcfDataVisible = false;
      } else {
        for(int q = 0;q<suggestionBcfData.length;q++) {
          if (suggestionBcfData[q]['default'] == '1') {
            suggestionBcfDataGroupValue = q;
            suggestionIdBcf = suggestionBcfData[q]['suggestion_id'];
            productSuggestionIdBcf = suggestionBcfData[q]['prod_suggestion_id'];
            suggestionPriceBcf = suggestionBcfData[q]['price'];
            // print('ang Woc id kay $suggestionBcfDataGroupValue');
            break;
          }
        }
      }

      if(suggestionCcData.toString() == '[[]]') {
        suggestionCcDataVisible = false;
      } else {
        for(int q = 0;q<suggestionCcData.length;q++) {
          if (suggestionCcData[q]['default'] == '1') {
            suggestionCcDataGroupValue = q;
            suggestionIdCc = suggestionCcData[q]['suggestion_id'];
            productSuggestionIdCc = suggestionCcData[q]['prod_suggestion_id'];
            suggestionPriceCc = suggestionCcData[q]['price'];
            // print('ang Woc id kay $suggestionBcfDataGroupValue');
            break;
          }
        }
      }

      if(suggestionComData.toString() == '[[]]') {
        suggestionComDataVisible = false;
      } else {
        for(int q = 0;q<suggestionComData.length;q++) {
          if (suggestionComData[q]['default'] == '1') {
            suggestionComDataGroupValue = q;
            suggestionIdCom = suggestionComData[q]['suggestion_id'];
            productSuggestionIdCom = suggestionComData[q]['prod_suggestion_id'];
            suggestionPriceCom = suggestionComData[q]['price'];
            // print('ang Woc id kay $suggestionBcfDataGroupValue');
            break;
          }
        }
      }

      if(suggestionCoftData.toString() == '[[]]') {
        suggestionCoftDataVisible = false;
      } else {
        for(int q = 0;q<suggestionCoftData.length;q++) {
          if (suggestionCoftData[q]['default'] == '1') {
            suggestionCoftDataGroupValue = q;
            suggestionIdCoft = suggestionCoftData[q]['suggestion_id'];
            productSuggestionIdCoft = suggestionCoftData[q]['prod_suggestion_id'];
            suggestionPriceCoft = suggestionCoftData[q]['price'];
            // print('ang Woc id kay $suggestionBcfDataGroupValue');
            break;
          }
        }
      }

      if(suggestionCymfData.toString() == '[[]]') {
        suggestionCymfDataVisible = false;
      } else {
        for(int q = 0;q<suggestionCymfData.length;q++) {
          if (suggestionCymfData[q]['default'] == '1') {
            suggestionCymfDataGroupValue = q;
            suggestionIdCymf = suggestionCymfData[q]['suggestion_id'];
            productSuggestionIdCymf = suggestionCymfData[q]['prod_suggestion_id'];
            suggestionPriceCymf = suggestionCymfData[q]['price'];
            // print('ang Woc id kay $suggestionBcfDataGroupValue');
            break;
          }
        }
      }

      if(suggestionTombData.toString() == '[[]]') {
        suggestionTombDataVisible = false;
      } else {
        for(int q = 0;q<suggestionTombData.length;q++) {
          if (suggestionTombData[q]['default'] == '1') {
            suggestionTombDataGroupValue = q;
            suggestionIdTomb = suggestionTombData[q]['suggestion_id'];
            productSuggestionIdTomb = suggestionTombData[q]['prod_suggestion_id'];
            suggestionPriceTomb = suggestionTombData[q]['price'];
            // print('ang Woc id kay $suggestionBcfDataGroupValue');
            break;
          }
        }
      }

      if(suggestionCosvData.toString() == '[[]]') {
        suggestionCosvDataVisible = false;
      } else {
        for(int q = 0;q<suggestionCosvData.length;q++) {
          if (suggestionCosvData[q]['default'] == '1') {
            suggestionCosvDataGroupValue = q;
            suggestionIdCosv = suggestionCosvData[q]['suggestion_id'];
            productSuggestionIdCosv = suggestionCosvData[q]['prod_suggestion_id'];
            suggestionPriceCosv = suggestionCosvData[q]['price'];
            // print('ang Woc id kay $suggestionBcfDataGroupValue');
            break;
          }
        }
      }

      if(suggestionTopData.toString() == '[[]]') {
        suggestionTopDataVisible = false;
      } else {
        for(int q = 0;q<suggestionTopData.length;q++) {
          if (suggestionTopData[q]['default'] == '1') {
            suggestionTopDataGroupValue = q;
            suggestionIdTop = suggestionTopData[q]['suggestion_id'];
            productSuggestionIdTop = suggestionTopData[q]['prod_suggestion_id'];
            suggestionPriceTop = suggestionTopData[q]['price'];
            // print('ang Woc id kay $suggestionBcfDataGroupValue');
            break;
          }
        }
      }

      if(suggestionTocwData.toString() == '[[]]') {
        suggestionTocwDataVisible = false;
      } else {
        for(int q = 0;q<suggestionTocwData.length;q++) {
          if (suggestionTocwData[q]['default'] == '1') {
            suggestionTocwDataGroupValue = q;
            suggestionIdTocw = suggestionTocwData[q]['suggestion_id'];
            productSuggestionIdTocw = suggestionTocwData[q]['prod_suggestion_id'];
            suggestionPriceTocw = suggestionTocwData[q]['price'];
            print('ang Woc id kay $suggestionTocwDataGroupValue');
            break;
          }
        }
      }

      if(suggestionNamelessData.toString() == '[[]]') {
        suggestionNamelessDataVisible = false;
      } else {
        for(int q = 0;q<suggestionNamelessData.length;q++) {
          if (suggestionNamelessData[q]['default'] == '1') {
            suggestionNamelessDataGroupValue = q;
            suggestionIdNameless = suggestionNamelessData[q]['suggestion_id'];
            productSuggestionIdNameless = suggestionNamelessData[q]['prod_suggestion_id'];
            suggestionPriceNameless = suggestionNamelessData[q]['price'];
            print('ang Woc id kay $suggestionNamelessDataGroupValue');
            break;
          }
        }
      }

      if (loadItemData[0]['price_per_gram'] != '0.00' && loadItemData[0]['no_specific_price'] == '1') {
        grams = true;
        price = false;
      }
    });
  }

  Future getSuggestion() async {
    var res = await db.getSuggestion(widget.prodId);
    if (!mounted) return;
    loadSuggestion = res['user_details'];
    isLoading = false;
    print(loadSuggestion);
    // print('ayaw kol');
  }

  Future addToCart() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String username = prefs.getString('s_customerId');
    if(username == null){
      Navigator.of(context).push(_signIn());
    } else {

      if (grams == true) {
        uomPrice = oCcy.format(totalAmount).toString();
      } else {
        uomPrice = uomPrice;
      }
      print(widget.prodId);
      print(uomPrice);

      var res = await db.addToCartNew(

          widget.prodId,
          uomId,
          _counter,
          uomPrice,
          measurement,

          choiceUomIdDrinks,
          choiceIdDrinks,
          choicePriceDrinks,

          choiceUomIdFries,
          choiceIdFries,
          choicePriceFries,

          choiceUomIdSides,
          choiceIdSides,
          choicePriceSides,

          suggestionIdFlavor,
          productSuggestionIdFlavor,
          suggestionPriceFlavor,

          suggestionIdWoc,
          productSuggestionIdWoc,
          suggestionPriceWoc,

          suggestionIdTos,
          productSuggestionIdTos,
          suggestionPriceTos,

          suggestionIdTon,
          productSuggestionIdTon,
          suggestionPriceTon,

          suggestionIdTops,
          productSuggestionIdTops,
          suggestionPriceTops,

          suggestionIdCoi,
          productSuggestionIdCoi,
          suggestionPriceCoi,

          suggestionIdCoslfm,
          productSuggestionIdCoslfm,
          suggestionPriceCoslfm,

          suggestionIdSink,
          productSuggestionIdSink,
          suggestionPriceSink,

          suggestionIdBcf,
          productSuggestionIdBcf,
          suggestionPriceBcf,

          suggestionIdCc,
          productSuggestionIdCc,
          suggestionPriceCc,

          suggestionIdCom,
          productSuggestionIdCom,
          suggestionPriceCom,

          suggestionIdCoft,
          productSuggestionIdCoft,
          suggestionPriceCoft,

          suggestionIdCymf,
          productSuggestionIdCymf,
          suggestionPriceCymf,

          suggestionIdTomb,
          productSuggestionIdTomb,
          suggestionPriceTomb,

          suggestionIdCosv,
          productSuggestionIdCosv,
          suggestionPriceCosv,

          suggestionIdTop,
          productSuggestionIdTop,
          suggestionPriceTop,

          suggestionIdTocw,
          productSuggestionIdTocw,
          suggestionPriceTocw,

          suggestionIdNameless,
          productSuggestionIdNameless,
          suggestionPriceNameless,

          selectedSideOnPrice,
          selectedSideItems,
          selectedSideItemsUom,

          selectedSideSides,
          selectedSideDessert,
          selectedSideDrinks
      );

      print(res);

      CoolAlert.show(
        context: context,
        type: CoolAlertType.success,
        text: "Successfully added to Cart",
        confirmBtnColor: Colors.deepOrangeAccent,
        backgroundColor: Colors.deepOrangeAccent,
        barrierDismissible: false,
        onConfirmBtnTap: () async {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        },
      );
    }
  }

  void change(String gram){
    print(gram);
    gramInput = double.parse(gram);
    // amountTender.text = oCcy.format(amt).toString();

    if(gramInput < defaultGram) {
      print('insufficient amount');
      totalPerGram.text = '';
    } else {
      totalAmount = gramInput * apg;
      totalPerGram.text = oCcy.format(totalAmount).toString();
    }
  }

  void _decrementCounter() {
    setState(() {
      _counter--;
      itemCount.text = _counter.toString();
      FocusScope.of(context).requestFocus(FocusNode());
    });
  }

  void _incrementCounter(){
    setState((){
      _counter++;
      itemCount.text = _counter.toString();
      FocusScope.of(context).requestFocus(FocusNode());
    });
  }

  @override
  void initState(){
    amountPerGram.text = defaultGram.toString();
    gramInput = oCcy.parse(amountPerGram.text);
    super.initState();
    uniOfMeasure = widget.unitOfMeasure;
    side1.clear();
    side2.clear();
    side3.clear();
    loadStore();
    // getSuggestion();
    onRefresh();
    loadStore();
    print(widget.prodId);

  }

  @override
  void dispose(){
    super.dispose();
    itemCount.dispose();
    amountPerGram.dispose();
    totalPerGram.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          titleSpacing: 0,
          brightness: Brightness.light,
          backgroundColor: Colors.white,
          elevation: 0.1,
          iconTheme: new IconThemeData(color: Colors.black),
          title: Text("Product Detail(s)",style: GoogleFonts.openSans(color:Colors.deepOrangeAccent,fontWeight: FontWeight.bold,fontSize: 18.0),),
          leading: IconButton(
            icon: Icon(CupertinoIcons.left_chevron, color: Colors.black54,size: 20,),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.search_outlined, color: Colors.black),
              onPressed: () async {
                Navigator.of(context).push(_search());
              }
            ),
            // IconButton(
            //     icon: Icon(Icons.info_outline, color: Colors.black),
            //     onPressed: () async {
            //
            //     }
            // ),
          ],
        ),
        body: isLoading ?
        Center(
          child: CircularProgressIndicator(
            valueColor: new AlwaysStoppedAnimation<Color>(Colors.deepOrange),
          ),
        ) :
        Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[

              Expanded(
                child: RefreshIndicator(
                  color: Colors.deepOrangeAccent,
                  onRefresh: onRefresh,
                  child:Scrollbar(
                    child: ListView(
                      physics: AlwaysScrollableScrollPhysics(),
                      children:[

                        ListView.builder(
                          physics: BouncingScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: 1,
                          itemBuilder: (BuildContext context, int index){
                            if (loadItemData[index]['variation'] == null){
                              variation = '';
                            } else {
                              variation = loadItemData[index]['variation'];
                            }
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children:[

                                Padding(
                                  padding: EdgeInsets.only(top: 10, bottom: 5),
                                  child: CachedNetworkImage(
                                    imageUrl: loadItemData[index]['image'],
                                    imageBuilder: (context, imageProvider) => Container(
                                      height: 190,
                                      width: 190,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: Colors.white,
                                        image: DecorationImage(
                                          image: imageProvider,
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                    ),
                                    placeholder: (context, url) => const CircularProgressIndicator(color: Colors.deepOrangeAccent,),
                                    errorWidget: (context, url, error) => Container(
                                      height: 190,
                                      width: 190,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: Colors.white,
                                        image: DecorationImage(
                                          image: AssetImage("assets/png/No_image_available.png"),
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                Padding(
                                  padding: EdgeInsets.fromLTRB(15.0, 0.0, 5.0, 5.0),
                                  child: new Text(loadItemData[index]['product_name'].toString(), style: GoogleFonts.openSans(fontWeight: FontWeight.bold,fontStyle: FontStyle.normal,fontSize: 16.0),),
                                ),

                                Visibility(
                                  visible: grams,
                                  child: Padding(
                                      padding:EdgeInsets.fromLTRB(15.0, 0.0, 5.0, 5.0),
                                      child: Text('₱ ${loadItemData[index]['price_per_gram'].toString()} / per gram', style: TextStyle(fontSize: 15,color: Colors.deepOrange,),)
                                  ),
                                ),

                                Visibility(
                                  visible: price,
                                  child: Padding(
                                      padding:EdgeInsets.fromLTRB(15.0, 0.0, 5.0, 5.0),
                                      child: Text('₱ $uomPrice', style: TextStyle(fontSize: 15,color: Colors.deepOrange,),)
                                  ),
                                ),

                                Padding(
                                    padding:EdgeInsets.fromLTRB(15.0, 0.0, 5.0, 5.0),
                                    child: Text(variation, style: TextStyle(fontSize: 15),)
                                ),

                                Padding(
                                  padding: EdgeInsets.fromLTRB(15.0, 0.0, 5.0, 5.0),
                                  child: new Text(loadItemData[index]['description'], style: GoogleFonts.openSans( fontStyle: FontStyle.normal,fontSize: 14.0), textAlign: TextAlign.center),
                                ),

                                Divider(color: Colors.deepOrangeAccent,),


                                ///grams
                                Visibility(
                                  visible: grams,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [

                                          Row(
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.fromLTRB(10, 10, 0, 10),
                                                child: Text('Grams',  style: TextStyle(fontSize: 17.0,fontWeight: FontWeight.bold)),
                                              ),

                                              Padding(
                                                padding: EdgeInsets.fromLTRB(10, 10, 0, 10),
                                                child: SizedBox(height: 35, width: 150,
                                                  child: TextFormField(
                                                    onTap: () {
                                                      amountPerGram.clear();
                                                      totalPerGram.clear();
                                                    },
                                                    textAlign: TextAlign.start,
                                                    textInputAction: TextInputAction.done,
                                                    cursorColor: Colors.deepOrange,
                                                    controller: amountPerGram,
                                                    style: TextStyle(fontSize: 13),
                                                    onChanged: (value)  => change(value),
                                                    keyboardType: TextInputType.number,
                                                    decoration: InputDecoration(
                                                      focusedBorder: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(3),
                                                        borderSide: BorderSide(
                                                            color: Colors.deepOrange.withOpacity(0.7),
                                                            width: 2.0),
                                                      ),
                                                      contentPadding: const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 10,
                                                      ),
                                                      labelStyle: TextStyle(color: Colors.black12, fontSize: 14),
                                                      hintStyle: const TextStyle(fontStyle: FontStyle
                                                          .normal,
                                                          fontSize: 14,
                                                          fontWeight: FontWeight.normal,
                                                          color: Colors.black),
                                                      border: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(3),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),

                                          Padding(
                                            padding: EdgeInsets.only(right: 10),
                                            child: SizedBox(height: 35, width: 100,
                                              child: TextFormField(
                                                textAlign: TextAlign.end,
                                                enabled: false,
                                                cursorColor: Colors.deepOrange,
                                                controller: totalPerGram,
                                                style: TextStyle(fontSize: 13),
                                                decoration: InputDecoration(
                                                  // prefixIcon: Icon(Icons.insert_chart,color: Colors.grey,),
                                                  contentPadding: EdgeInsets.fromLTRB(10.0, 0, 10.0, 0),
                                                  focusedBorder:OutlineInputBorder(
                                                    borderSide: BorderSide(color: Colors.deepOrange, width: 2.0),
                                                  ),
                                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(3.0)),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                ///change Sizes
                                Visibility(
                                  visible:uomDataVisible,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [

                                      Padding(
                                        padding: EdgeInsets.fromLTRB(10.0, 10.0, 0.0, 0.0),
                                        child: Text("Change size", style: TextStyle(fontSize: 16.0,fontWeight: FontWeight.bold, color: Colors.black54),),
                                      ),

                                      Padding(
                                        padding: EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 10.0),
                                        child: ListView.builder(
                                          physics: NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          itemCount: uomData == null ? 0 : uomData.length,
                                          itemBuilder: (BuildContext context, int index2) {
                                            String uomName = "";

                                            if (uomData[index2]['unit']!=null) {
                                              uomName = uomData[index2]['unit'].toString();
                                            }
                                            return Column(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [

                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [

                                                    Flexible(
                                                      fit: FlexFit.loose,
                                                      child: SizedBox(height: 35,
                                                        child: RadioListTile(
                                                          visualDensity: const VisualDensity(
                                                            horizontal: VisualDensity.minimumDensity,
                                                            vertical: VisualDensity.minimumDensity,
                                                          ),
                                                          contentPadding: EdgeInsets.all(0),
                                                          activeColor: Colors.deepOrange,
                                                          title:  Transform.translate(
                                                            offset: const Offset(-10, 0),
                                                            child: Row(
                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                              children: [

                                                                Expanded(
                                                                  child: Text('$uomName', overflow: TextOverflow.ellipsis, style: TextStyle(fontStyle: FontStyle.normal, fontSize: 13)),
                                                                ),
                                                                Text('₱ ${uomData[index2]['price']}', style: TextStyle(fontStyle: FontStyle.normal, fontSize: 13)),
                                                              ],
                                                            ),
                                                          ),
                                                          value: index2,
                                                          groupValue: uomDataGroupValue,
                                                          onChanged: (newValue) {
                                                            setState((){
                                                              uomDataGroupValue = newValue;
                                                              uomPrice = uomData[index2]['price'];
                                                              uomId = uomData[index2]['uom_id'];
                                                              print(uomId);
                                                            });
                                                          },
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                ///flavor
                                // Visibility(
                                //   visible:flavorDataVisible,
                                //   child: Column(
                                //     crossAxisAlignment: CrossAxisAlignment.start,
                                //     children: [
                                //
                                //       Padding(
                                //         padding: EdgeInsets.fromLTRB(10.0, 10.0, 0.0, 0.0),
                                //         child: Text("Select Flavor",style: TextStyle(fontSize: 15.0,fontWeight: FontWeight.bold),),
                                //       ),
                                //
                                //       Padding(
                                //         padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 10.0),
                                //         child: ListView.builder(
                                //           physics: NeverScrollableScrollPhysics(),
                                //           shrinkWrap: true,
                                //           itemCount:flavorData == null ? 0 : flavorData.length,
                                //           itemBuilder: (BuildContext context, int index3) {
                                //             String uomName = "";
                                //             String flavorPriceD;
                                //             if(flavorData[index3]['price'] == '0.00') {
                                //               flavorPriceD = "";
                                //             } else {
                                //               flavorPriceD ='+ ₱ ${flavorData[index3]['price']}';
                                //             }
                                //             if (flavorData[index3]['unit']!=null) {
                                //               uomName = flavorData[index3]['unit'].toString();
                                //             }
                                //             return Column(
                                //               crossAxisAlignment: CrossAxisAlignment.start,
                                //               children: [
                                //
                                //                 Row(
                                //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                //                   children: [
                                //
                                //                     Flexible(
                                //                       fit: FlexFit.loose,
                                //                       child: SizedBox(height: 35,
                                //                         child: RadioListTile(
                                //                           visualDensity: const VisualDensity(
                                //                             horizontal: VisualDensity.minimumDensity,
                                //                             vertical: VisualDensity.minimumDensity,
                                //                           ),
                                //                           contentPadding: EdgeInsets.all(0),
                                //                           activeColor: Colors.deepOrange,
                                //                           title: Transform.translate(
                                //                             offset: const Offset(-10, 0),
                                //                             child: Row(
                                //                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                //                               children: [
                                //
                                //                                 Text('${flavorData[index3]['flavor_name']}  $uomName', style: TextStyle(fontStyle: FontStyle.normal, fontSize: 13)),
                                //                                 Text('$flavorPriceD', style: TextStyle(fontStyle: FontStyle.normal, fontSize: 13)),
                                //                               ],
                                //                             ),
                                //                           ),
                                //                           value: index3,
                                //                           groupValue: flavorDataGroupValue,
                                //                           onChanged: (newValue) {
                                //                             setState((){
                                //                               flavorDataGroupValue = newValue;
                                //                               flavorId = flavorData[index3]['flavor_id'];
                                //                               flavorPrice = flavorData[index3]['price'];
                                //                               print(flavorId);
                                //                             });
                                //                           },
                                //                         )
                                //                       )
                                //                     )
                                //                   ],
                                //                 )
                                //               ],
                                //             );
                                //           }
                                //         ),
                                //       ),
                                //     ],
                                //   ),
                                // ),

                                ///suggestionFlavor
                                Visibility(
                                  visible:suggestionFlavorDataVisible,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [

                                      Padding(
                                        padding: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                                        child: Text("Select Flavor",style: TextStyle(fontSize: 15.0,fontWeight: FontWeight.bold, color: Colors.black54),),
                                      ),

                                      Padding(
                                        padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 10.0),
                                        child: ListView.builder(
                                          physics: NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          itemCount: suggestionFlavorData == null ? 0 : suggestionFlavorData.length,
                                          itemBuilder: (BuildContext context, int index3) {

                                            String uomName = "";
                                            String flavorPriceD;
                                            if(suggestionFlavorData[index3]['price'] == '0.00') {
                                              flavorPriceD = "";
                                            } else {
                                              flavorPriceD ='+ ₱ ${suggestionFlavorData[index3]['price']}';
                                            }
                                            if (suggestionFlavorData[index3]['unit']!=null) {
                                              uomName = suggestionFlavorData[index3]['unit'].toString();
                                            }

                                            return InkWell(
                                              child: Padding(
                                                padding: EdgeInsets.all(0),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [

                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [

                                                        Flexible(
                                                          fit: FlexFit.loose,
                                                          child: SizedBox(height: 35,
                                                            child: RadioListTile(
                                                              visualDensity: const VisualDensity(
                                                                horizontal: VisualDensity.minimumDensity,
                                                                vertical: VisualDensity.minimumDensity,
                                                              ),
                                                              contentPadding: EdgeInsets.all(0),
                                                              activeColor: Colors.deepOrange,
                                                              title: Transform.translate(
                                                                offset: const Offset(-10, 0),
                                                                child: Row(
                                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                  children: [
                                                                    Text('${suggestionFlavorData[index3]['suggestion_name']} ', style: TextStyle(fontStyle: FontStyle.normal, fontSize: 13)),
                                                                    Text('$flavorPriceD', style: TextStyle(fontStyle: FontStyle.normal, fontSize: 13)),
                                                                  ],
                                                                ),
                                                              ),
                                                              value: index3,
                                                              groupValue: suggestionFlavorDataGroupValue,
                                                              onChanged: (newValue) {
                                                                setState((){
                                                                  print(newValue);
                                                                  suggestionFlavorDataGroupValue = newValue;
                                                                  suggestionIdFlavor = suggestionFlavorData[index3]['suggestion_id'];
                                                                  productSuggestionIdFlavor = suggestionFlavorData[index3]['prod_suggestion_id'];
                                                                  suggestionPriceFlavor = suggestionFlavorData[index3]['price'];
                                                                });
                                                              },
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                ///suggestion Ways of Cooking
                                Visibility(
                                  visible:suggestionWocDataVisible,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [

                                      Padding(
                                        padding: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                                        child: Text("Select Ways of Cooking",style: TextStyle(fontSize: 15.0,fontWeight: FontWeight.bold, color: Colors.black54),),
                                      ),

                                      Padding(
                                        padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 10.0),
                                        child: ListView.builder(
                                          physics: NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          itemCount: suggestionWocData == null ? 0 : suggestionWocData.length,
                                          itemBuilder: (BuildContext context, int index4) {

                                            String uomName = "";
                                            String wocPriceD;
                                            if(suggestionWocData[index4]['price'] == '0.00') {
                                              wocPriceD = "";
                                            } else {
                                              wocPriceD ='+ ₱ ${suggestionWocData[index4]['price']}';
                                            }
                                            if (suggestionWocData[index4]['unit']!=null) {
                                              uomName = suggestionWocData[index4]['unit'].toString();
                                            }

                                            return InkWell(
                                              child: Padding(
                                                padding: EdgeInsets.all(0),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [

                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [

                                                        Flexible(
                                                          fit: FlexFit.loose,
                                                          child: SizedBox(height: 35,
                                                            child: RadioListTile(
                                                              visualDensity: const VisualDensity(
                                                                horizontal: VisualDensity.minimumDensity,
                                                                vertical: VisualDensity.minimumDensity,
                                                              ),
                                                              contentPadding: EdgeInsets.all(0),
                                                              activeColor: Colors.deepOrange,
                                                              title: Transform.translate(
                                                                offset: const Offset(-10, 0),
                                                                child: Row(
                                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                  children: [
                                                                    Text('${suggestionWocData[index4]['suggestion_name']} ', style: TextStyle(fontStyle: FontStyle.normal, fontSize: 13)),
                                                                    Text('$wocPriceD', style: TextStyle(fontStyle: FontStyle.normal, fontSize: 13)),
                                                                  ],
                                                                ),
                                                              ),
                                                              value: index4,
                                                              groupValue: suggestionWocDataGroupValue,
                                                              onChanged: (newValue) {
                                                                setState((){
                                                                  print(newValue);
                                                                  suggestionWocDataGroupValue = newValue;
                                                                  suggestionIdWoc = suggestionWocData[index4]['suggestion_id'];
                                                                  productSuggestionIdWoc = suggestionWocData[index4]['prod_suggestion_id'];
                                                                  suggestionPriceWoc = suggestionWocData[index4]['price'];
                                                                });
                                                              },
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    )
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                ///Type of Sauce
                                Visibility(
                                  visible:suggestionTosDataVisible,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [

                                      Padding(
                                        padding: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                                        child: Text("Select Type of Sauce",style: TextStyle(fontSize: 15.0,fontWeight: FontWeight.bold, color: Colors.black54),),
                                      ),

                                      Padding(
                                        padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 10.0),
                                        child: ListView.builder(
                                          physics: NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          itemCount: suggestionTosData == null ? 0 : suggestionTosData.length,
                                          itemBuilder: (BuildContext context, int index5) {

                                            String uomName = "";
                                            String tosPriceD;
                                            if(suggestionTosData[index5]['price'] == '0.00') {
                                              tosPriceD = "";
                                            } else {
                                              tosPriceD ='+ ₱ ${suggestionTosData[index5]['price']}';
                                            }
                                            if (suggestionTosData[index5]['unit']!=null) {
                                              uomName = suggestionTosData[index5]['unit'].toString();
                                            }

                                            return InkWell(
                                              child: Padding(
                                                padding: EdgeInsets.all(0),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [

                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [

                                                        Flexible(
                                                          fit: FlexFit.loose,
                                                          child: SizedBox(height: 35,
                                                            child: RadioListTile(
                                                              visualDensity: const VisualDensity(
                                                                horizontal: VisualDensity.minimumDensity,
                                                                vertical: VisualDensity.minimumDensity,
                                                              ),
                                                              contentPadding: EdgeInsets.all(0),
                                                              activeColor: Colors.deepOrange,
                                                              title: Transform.translate(
                                                                offset: const Offset(-10, 0),
                                                                child: Row(
                                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                  children: [
                                                                    Text('${suggestionTosData[index5]['suggestion_name']} ', style: TextStyle(fontStyle: FontStyle.normal, fontSize: 13)),
                                                                    Text('$tosPriceD', style: TextStyle(fontStyle: FontStyle.normal, fontSize: 13)),
                                                                  ],
                                                                ),
                                                              ),
                                                              value: index5,
                                                              groupValue: suggestionTosDataGroupValue,
                                                              onChanged: (newValue) {
                                                                setState((){
                                                                  print(newValue);
                                                                  suggestionTosDataGroupValue = newValue;
                                                                  suggestionIdTos = suggestionTosData[index5]['suggestion_id'];
                                                                  productSuggestionIdTos = suggestionTosData[index5]['prod_suggestion_id'];
                                                                  suggestionPriceTos = suggestionTosData[index5]['price'];
                                                                });
                                                              },
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                ///Type of Noodles
                                Visibility(
                                  visible:suggestionTonDataVisible,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [

                                      Padding(
                                        padding: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                                        child: Text("Select Type of Noodles",style: TextStyle(fontSize: 15.0,fontWeight: FontWeight.bold, color: Colors.black54),),
                                      ),

                                      Padding(
                                        padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 10.0),
                                        child: ListView.builder(
                                          physics: NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          itemCount: suggestionTonData == null ? 0 : suggestionTonData.length,
                                          itemBuilder: (BuildContext context, int index6) {

                                            String uomName = "";
                                            String tonPriceD;
                                            if(suggestionTonData[index6]['price'] == '0.00') {
                                              tonPriceD = "";
                                            } else {
                                              tonPriceD ='+ ₱ ${suggestionTonData[index6]['price']}';
                                            }
                                            if (suggestionTonData[index6]['unit']!=null) {
                                              uomName = suggestionTonData[index6]['unit'].toString();
                                            }

                                            return InkWell(
                                              child: Padding(
                                                padding: EdgeInsets.all(0),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [

                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [

                                                        Flexible(
                                                          fit: FlexFit.loose,
                                                          child: SizedBox(height: 35,
                                                            child: RadioListTile(
                                                              visualDensity: const VisualDensity(
                                                                horizontal: VisualDensity.minimumDensity,
                                                                vertical: VisualDensity.minimumDensity,
                                                              ),
                                                              contentPadding: EdgeInsets.all(0),
                                                              activeColor: Colors.deepOrange,
                                                              title: Transform.translate(
                                                                offset: const Offset(-10, 0),
                                                                child: Row(
                                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                  children: [
                                                                    Text('${suggestionTonData[index6]['suggestion_name']} ', style: TextStyle(fontStyle: FontStyle.normal, fontSize: 13)),
                                                                    Text('$tonPriceD', style: TextStyle(fontStyle: FontStyle.normal, fontSize: 13)),
                                                                  ],
                                                                ),
                                                              ),
                                                              value: index6,
                                                              groupValue: suggestionTonDataGroupValue,
                                                              onChanged: (newValue) {
                                                                setState((){
                                                                  print(newValue);
                                                                  suggestionTonDataGroupValue = newValue;
                                                                  suggestionIdTon = suggestionTonData[index6]['suggestion_id'];
                                                                  productSuggestionIdTon = suggestionTonData[index6]['prod_suggestion_id'];
                                                                  suggestionPriceTon = suggestionTonData[index6]['price'];
                                                                });
                                                              },
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                ///Toppings
                                Visibility(
                                  visible:suggestionTopsDataVisible,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [

                                      Padding(
                                        padding: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                                        child: Text("Select Toppings",style: TextStyle(fontSize: 15.0,fontWeight: FontWeight.bold, color: Colors.black54),),
                                      ),

                                      Padding(
                                        padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 10.0),
                                        child: ListView.builder(
                                          physics: NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          itemCount: suggestionTopsData == null ? 0 : suggestionTopsData.length,
                                          itemBuilder: (BuildContext context, int index7) {

                                            String uomName = "";
                                            String topsPriceD;
                                            if(suggestionTopsData[index7]['price'] == '0.00') {
                                              topsPriceD = "";
                                            } else {
                                              topsPriceD ='+ ₱ ${suggestionTopsData[index7]['price']}';
                                            }
                                            if (suggestionTopsData[index7]['unit']!=null) {
                                              uomName = suggestionTopsData[index7]['unit'].toString();
                                            }

                                            return InkWell(
                                              child: Padding(
                                                padding: EdgeInsets.all(0),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [

                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [

                                                        Flexible(
                                                          fit: FlexFit.loose,
                                                          child: SizedBox(height: 35,
                                                            child: RadioListTile(
                                                              visualDensity: const VisualDensity(
                                                                horizontal: VisualDensity.minimumDensity,
                                                                vertical: VisualDensity.minimumDensity,
                                                              ),
                                                              contentPadding: EdgeInsets.all(0),
                                                              activeColor: Colors.deepOrange,
                                                              title: Transform.translate(
                                                                offset: const Offset(-10, 0),
                                                                child: Row(
                                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                  children: [
                                                                    Text('${suggestionTopsData[index7]['suggestion_name']} ', style: TextStyle(fontStyle: FontStyle.normal, fontSize: 13)),
                                                                    Text('$topsPriceD', style: TextStyle(fontStyle: FontStyle.normal, fontSize: 13)),
                                                                  ],
                                                                ),
                                                              ),
                                                              value: index7,
                                                              groupValue: suggestionTopsDataGroupValue,
                                                              onChanged: (newValue) {
                                                                setState((){
                                                                  print(newValue);
                                                                  suggestionTopsDataGroupValue = newValue;
                                                                  suggestionIdTops = suggestionTopsData[index7]['suggestion_id'];
                                                                  productSuggestionIdTops = suggestionTopsData[index7]['prod_suggestion_id'];
                                                                  suggestionPriceTops = suggestionTopsData[index7]['price'];
                                                                });
                                                              },
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                ///Choice of Ice
                                Visibility(
                                  visible:suggestionCoiDataVisible,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [

                                      Padding(
                                        padding: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                                        child: Text("Select Choice of Ice",style: TextStyle(fontSize: 15.0,fontWeight: FontWeight.bold, color: Colors.black54),),
                                      ),

                                      Padding(
                                        padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 10.0),
                                        child: ListView.builder(
                                          physics: NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          itemCount: suggestionCoiData == null ? 0 : suggestionCoiData.length,
                                          itemBuilder: (BuildContext context, int index8) {

                                            String uomName = "";
                                            String coiPriceD;
                                            if(suggestionCoiData[index8]['price'] == '0.00') {
                                              coiPriceD = "";
                                            } else {
                                              coiPriceD ='+ ₱ ${suggestionCoiData[index8]['price']}';
                                            }
                                            if (suggestionCoiData[index8]['unit']!=null) {
                                              uomName = suggestionCoiData[index8]['unit'].toString();
                                            }

                                            return InkWell(
                                              child: Padding(
                                                padding: EdgeInsets.all(0),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [

                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [

                                                        Flexible(
                                                          fit: FlexFit.loose,
                                                          child: SizedBox(height: 35,
                                                            child: RadioListTile(
                                                              visualDensity: const VisualDensity(
                                                                horizontal: VisualDensity.minimumDensity,
                                                                vertical: VisualDensity.minimumDensity,
                                                              ),
                                                              contentPadding: EdgeInsets.all(0),
                                                              activeColor: Colors.deepOrange,
                                                              title: Transform.translate(
                                                                offset: const Offset(-10, 0),
                                                                child: Row(
                                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                  children: [
                                                                    Text('${suggestionCoiData[index8]['suggestion_name']} ', style: TextStyle(fontStyle: FontStyle.normal, fontSize: 13)),
                                                                    Text('$coiPriceD', style: TextStyle(fontStyle: FontStyle.normal, fontSize: 13)),
                                                                  ],
                                                                ),
                                                              ),
                                                              value: index8,
                                                              groupValue: suggestionCoiDataGroupValue,
                                                              onChanged: (newValue) {
                                                                setState((){
                                                                  print(newValue);
                                                                  suggestionCoiDataGroupValue = newValue;
                                                                  suggestionIdCoi = suggestionCoiData[index8]['suggestion_id'];
                                                                  productSuggestionIdCoi = suggestionCoiData[index8]['prod_suggestion_id'];
                                                                  suggestionPriceCoi = suggestionCoiData[index8]['price'];
                                                                });
                                                              },
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                ///Choice of Sweetness level for Milktea
                                Visibility(
                                  visible:suggestionCoslfmDataVisible,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [

                                      Padding(
                                        padding: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                                        child: Text("Select Choice of Sweetness Level for Milktea",style: TextStyle(fontSize: 15.0,fontWeight: FontWeight.bold, color: Colors.black54),),
                                      ),

                                      Padding(
                                        padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 10.0),
                                        child: ListView.builder(
                                          physics: NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          itemCount: suggestionCoslfmData == null ? 0 : suggestionCoslfmData.length,
                                          itemBuilder: (BuildContext context, int index9) {

                                            String uomName = "";
                                            String coslfmPriceD;
                                            if(suggestionCoslfmData[index9]['price'] == '0.00') {
                                              coslfmPriceD = "";
                                            } else {
                                              coslfmPriceD ='+ ₱ ${suggestionCoslfmData[index9]['price']}';
                                            }
                                            if (suggestionCoslfmData[index9]['unit']!=null) {
                                              uomName = suggestionCoslfmData[index9]['unit'].toString();
                                            }

                                            return InkWell(
                                              child: Padding(
                                                padding: EdgeInsets.all(0),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [

                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [

                                                        Flexible(
                                                          fit: FlexFit.loose,
                                                          child: SizedBox(height: 35,
                                                            child: RadioListTile(
                                                              visualDensity: const VisualDensity(
                                                                horizontal: VisualDensity.minimumDensity,
                                                                vertical: VisualDensity.minimumDensity,
                                                              ),
                                                              contentPadding: EdgeInsets.all(0),
                                                              activeColor: Colors.deepOrange,
                                                              title: Transform.translate(
                                                                offset: const Offset(-10, 0),
                                                                child: Row(
                                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                  children: [
                                                                    Text('${suggestionCoslfmData[index9]['suggestion_name']} ', style: TextStyle(fontStyle: FontStyle.normal, fontSize: 13)),
                                                                    Text('$coslfmPriceD', style: TextStyle(fontStyle: FontStyle.normal, fontSize: 13)),
                                                                  ],
                                                                ),
                                                              ),
                                                              value: index9,
                                                              groupValue: suggestionCoslfmDataGroupValue,
                                                              onChanged: (newValue) {
                                                                setState((){
                                                                  print(newValue);
                                                                  suggestionCoslfmDataGroupValue = newValue;
                                                                  suggestionIdCoslfm = suggestionCoslfmData[index9]['suggestion_id'];
                                                                  productSuggestionIdCoslfm = suggestionCoslfmData[index9]['prod_suggestion_id'];
                                                                  suggestionPriceCoslfm = suggestionCoslfmData[index9]['price'];
                                                                });
                                                              },
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                ///Sinkers
                                Visibility(
                                  visible:suggestionSinkDataVisible,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [

                                      Padding(
                                        padding: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                                        child: Text("Select Sinkers",style: TextStyle(fontSize: 15.0,fontWeight: FontWeight.bold, color: Colors.black54),),
                                      ),

                                      Padding(
                                        padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 10.0),
                                        child: ListView.builder(
                                          physics: NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          itemCount: suggestionSinkData == null ? 0 : suggestionSinkData.length,
                                          itemBuilder: (BuildContext context, int index10) {

                                            String uomName = "";
                                            String sinkPriceD;
                                            if(suggestionSinkData[index10]['price'] == '0.00') {
                                              sinkPriceD = "";
                                            } else {
                                              sinkPriceD ='+ ₱ ${suggestionSinkData[index10]['price']}';
                                            }
                                            if (suggestionSinkData[index10]['unit']!=null) {
                                              uomName = suggestionSinkData[index10]['unit'].toString();
                                            }

                                            return InkWell(
                                              child: Padding(
                                                padding: EdgeInsets.all(0),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [

                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [

                                                        Flexible(
                                                          fit: FlexFit.loose,
                                                          child: SizedBox(height: 35,
                                                            child: RadioListTile(
                                                              visualDensity: const VisualDensity(
                                                                horizontal: VisualDensity.minimumDensity,
                                                                vertical: VisualDensity.minimumDensity,
                                                              ),
                                                              contentPadding: EdgeInsets.all(0),
                                                              activeColor: Colors.deepOrange,
                                                              title: Transform.translate(
                                                                offset: const Offset(-10, 0),
                                                                child: Row(
                                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                  children: [
                                                                    Text('${suggestionSinkData[index10]['suggestion_name']} ', style: TextStyle(fontStyle: FontStyle.normal, fontSize: 13)),
                                                                    Text('$sinkPriceD', style: TextStyle(fontStyle: FontStyle.normal, fontSize: 13)),
                                                                  ],
                                                                ),
                                                              ),
                                                              value: index10,
                                                              groupValue: suggestionSinkDataGroupValue,
                                                              onChanged: (newValue) {
                                                                setState((){
                                                                  print(newValue);
                                                                  suggestionSinkDataGroupValue = newValue;
                                                                  suggestionIdSink= suggestionSinkData[index10]['suggestion_id'];
                                                                  productSuggestionIdSink = suggestionSinkData[index10]['prod_suggestion_id'];
                                                                  suggestionPriceSink = suggestionSinkData[index10]['price'];
                                                                });
                                                              },
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                ///Basic Crepe Flavor
                                Visibility(
                                  visible:suggestionBcfDataVisible,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [

                                      Padding(
                                        padding: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                                        child: Text("Select Basic Crepe Flavor",style: TextStyle(fontSize: 15.0,fontWeight: FontWeight.bold, color: Colors.black54),),
                                      ),

                                      Padding(
                                        padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 10.0),
                                        child: ListView.builder(
                                          physics: NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          itemCount: suggestionBcfData == null ? 0 : suggestionBcfData.length,
                                          itemBuilder: (BuildContext context, int index11) {

                                            String uomName = "";
                                            String bcfPriceD;
                                            if(suggestionBcfData[index11]['price'] == '0.00') {
                                              bcfPriceD = "";
                                            } else {
                                              bcfPriceD ='+ ₱ ${suggestionBcfData[index11]['price']}';
                                            }
                                            if (suggestionBcfData[index11]['unit']!=null) {
                                              uomName = suggestionBcfData[index11]['unit'].toString();
                                            }

                                            return InkWell(
                                              child: Padding(
                                                padding: EdgeInsets.all(0),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [

                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [

                                                        Flexible(
                                                          fit: FlexFit.loose,
                                                          child: SizedBox(height: 35,
                                                            child: RadioListTile(
                                                              visualDensity: const VisualDensity(
                                                                horizontal: VisualDensity.minimumDensity,
                                                                vertical: VisualDensity.minimumDensity,
                                                              ),
                                                              contentPadding: EdgeInsets.all(0),
                                                              activeColor: Colors.deepOrange,
                                                              title: Transform.translate(
                                                                offset: const Offset(-10, 0),
                                                                child: Row(
                                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                  children: [
                                                                    Text('${suggestionBcfData[index11]['suggestion_name']} ', style: TextStyle(fontStyle: FontStyle.normal, fontSize: 13)),
                                                                    Text('$bcfPriceD', style: TextStyle(fontStyle: FontStyle.normal, fontSize: 13)),
                                                                  ],
                                                                ),
                                                              ),
                                                              value: index11,
                                                              groupValue: suggestionBcfDataGroupValue,
                                                              onChanged: (newValue) {
                                                                setState((){
                                                                  print(newValue);
                                                                  suggestionBcfDataGroupValue = newValue;
                                                                  suggestionIdBcf = suggestionBcfData[index11]['suggestion_id'];
                                                                  productSuggestionIdBcf = suggestionBcfData[index11]['prod_suggestion_id'];
                                                                  suggestionPriceBcf = suggestionBcfData[index11]['price'];
                                                                });
                                                              },
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                ///Classic Crepe
                                Visibility(
                                  visible:suggestionCcDataVisible,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [

                                      Padding(
                                        padding: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                                        child: Text("Select Classic Crepe",style: TextStyle(fontSize: 15.0,fontWeight: FontWeight.bold, color: Colors.black54),),
                                      ),

                                      Padding(
                                        padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 10.0),
                                        child: ListView.builder(
                                          physics: NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          itemCount: suggestionCcData == null ? 0 : suggestionCcData.length,
                                          itemBuilder: (BuildContext context, int index12) {

                                            String uomName = "";
                                            String ccPriceD;
                                            if(suggestionCcData[index12]['price'] == '0.00') {
                                              ccPriceD = "";
                                            } else {
                                              ccPriceD ='+ ₱ ${suggestionCcData[index12]['price']}';
                                            }
                                            if (suggestionCcData[index12]['unit']!=null) {
                                              uomName = suggestionCcData[index12]['unit'].toString();
                                            }

                                            return InkWell(
                                              child: Padding(
                                                padding: EdgeInsets.all(0),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [

                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [

                                                        Flexible(
                                                          fit: FlexFit.loose,
                                                          child: SizedBox(height: 35,
                                                            child: RadioListTile(
                                                              visualDensity: const VisualDensity(
                                                                horizontal: VisualDensity.minimumDensity,
                                                                vertical: VisualDensity.minimumDensity,
                                                              ),
                                                              contentPadding: EdgeInsets.all(0),
                                                              activeColor: Colors.deepOrange,
                                                              title: Transform.translate(
                                                                offset: const Offset(-10, 0),
                                                                child: Row(
                                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                  children: [
                                                                    Text('${suggestionCcData[index12]['suggestion_name']} ', style: TextStyle(fontStyle: FontStyle.normal, fontSize: 13)),
                                                                    Text('$ccPriceD', style: TextStyle(fontStyle: FontStyle.normal, fontSize: 13)),
                                                                  ],
                                                                ),
                                                              ),
                                                              value: index12,
                                                              groupValue: suggestionCcDataGroupValue,
                                                              onChanged: (newValue) {
                                                                setState((){
                                                                  print(newValue);
                                                                  suggestionCcDataGroupValue = newValue;
                                                                  suggestionIdCc = suggestionCcData[index12]['suggestion_id'];
                                                                  productSuggestionIdCc = suggestionCcData[index12]['prod_suggestion_id'];
                                                                  suggestionPriceCc = suggestionCcData[index12]['price'];
                                                                });
                                                              },
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                ///Choice of MilkTea
                                Visibility(
                                  visible:suggestionComDataVisible,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [

                                      Padding(
                                        padding: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                                        child: Text("Select Choice of Milktea",style: TextStyle(fontSize: 15.0,fontWeight: FontWeight.bold, color: Colors.black54),),
                                      ),

                                      Padding(
                                        padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 10.0),
                                        child: ListView.builder(
                                          physics: NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          itemCount: suggestionComData == null ? 0 : suggestionComData.length,
                                          itemBuilder: (BuildContext context, int index13) {

                                            String uomName = "";
                                            String comPriceD;
                                            if(suggestionComData[index13]['price'] == '0.00') {
                                              comPriceD = "";
                                            } else {
                                              comPriceD ='+ ₱ ${suggestionComData[index13]['price']}';
                                            }
                                            if (suggestionComData[index13]['unit']!=null) {
                                              uomName = suggestionComData[index13]['unit'].toString();
                                            }

                                            return InkWell(
                                              child: Padding(
                                                padding: EdgeInsets.all(0),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [

                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [

                                                        Flexible(
                                                          fit: FlexFit.loose,
                                                          child: SizedBox(height: 35,
                                                            child: RadioListTile(
                                                              visualDensity: const VisualDensity(
                                                                horizontal: VisualDensity.minimumDensity,
                                                                vertical: VisualDensity.minimumDensity,
                                                              ),
                                                              contentPadding: EdgeInsets.all(0),
                                                              activeColor: Colors.deepOrange,
                                                              title: Transform.translate(
                                                                offset: const Offset(-10, 0),
                                                                child: Row(
                                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                  children: [
                                                                    Text('${suggestionComData[index13]['suggestion_name']} ', style: TextStyle(fontStyle: FontStyle.normal, fontSize: 13)),
                                                                    Text('$comPriceD', style: TextStyle(fontStyle: FontStyle.normal, fontSize: 13)),
                                                                  ],
                                                                ),
                                                              ),
                                                              value: index13,
                                                              groupValue: suggestionComDataGroupValue,
                                                              onChanged: (newValue) {
                                                                setState((){
                                                                  print(newValue);
                                                                  suggestionComDataGroupValue = newValue;
                                                                  suggestionIdCom = suggestionComData[index13]['suggestion_id'];
                                                                  productSuggestionIdCom = suggestionComData[index13]['prod_suggestion_id'];
                                                                  suggestionPriceCom = suggestionComData[index13]['price'];
                                                                });
                                                              },
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                ///Choice of Fruit Tea
                                Visibility(
                                  visible:suggestionCoftDataVisible,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [

                                      Padding(
                                        padding: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                                        child: Text("Select Choice of Fruit Tea",style: TextStyle(fontSize: 15.0,fontWeight: FontWeight.bold, color: Colors.black54),),
                                      ),

                                      Padding(
                                        padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 10.0),
                                        child: ListView.builder(
                                          physics: NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          itemCount: suggestionCoftData == null ? 0 : suggestionCoftData.length,
                                          itemBuilder: (BuildContext context, int index14) {

                                            String uomName = "";
                                            String coftPriceD;
                                            if(suggestionCoftData[index14]['price'] == '0.00') {
                                              coftPriceD = "";
                                            } else {
                                              coftPriceD ='+ ₱ ${suggestionCoftData[index14]['price']}';
                                            }
                                            if (suggestionCoftData[index14]['unit']!=null) {
                                              uomName = suggestionCoftData[index14]['unit'].toString();
                                            }

                                            return InkWell(
                                              child: Padding(
                                                padding: EdgeInsets.all(0),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [

                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [

                                                        Flexible(
                                                          fit: FlexFit.loose,
                                                          child: SizedBox(height: 35,
                                                            child: RadioListTile(
                                                              visualDensity: const VisualDensity(
                                                                horizontal: VisualDensity.minimumDensity,
                                                                vertical: VisualDensity.minimumDensity,
                                                              ),
                                                              contentPadding: EdgeInsets.all(0),
                                                              activeColor: Colors.deepOrange,
                                                              title: Transform.translate(
                                                                offset: const Offset(-10, 0),
                                                                child: Row(
                                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                  children: [
                                                                    Text('${suggestionCoftData[index14]['suggestion_name']} ', style: TextStyle(fontStyle: FontStyle.normal, fontSize: 13)),
                                                                    Text('$coftPriceD', style: TextStyle(fontStyle: FontStyle.normal, fontSize: 13)),
                                                                  ],
                                                                ),
                                                              ),
                                                              value: index14,
                                                              groupValue: suggestionCoftDataGroupValue,
                                                              onChanged: (newValue) {
                                                                setState((){
                                                                  print(newValue);
                                                                  suggestionCoftDataGroupValue = newValue;
                                                                  suggestionIdCoft = suggestionCoftData[index14]['suggestion_id'];
                                                                  productSuggestionIdCoft = suggestionCoftData[index14]['prod_suggestion_id'];
                                                                  suggestionPriceCoft = suggestionCoftData[index14]['price'];
                                                                });
                                                              },
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                ///Choose your Meat Filling
                                Visibility(
                                  visible:suggestionCymfDataVisible,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [

                                      Padding(
                                        padding: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                                        child: Text("Choose your Meat Filling",style: TextStyle(fontSize: 15.0,fontWeight: FontWeight.bold, color: Colors.black54),),
                                      ),

                                      Padding(
                                        padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 10.0),
                                        child: ListView.builder(
                                          physics: NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          itemCount: suggestionCymfData == null ? 0 : suggestionCymfData.length,
                                          itemBuilder: (BuildContext context, int index15) {

                                            String uomName = "";
                                            String cymfPriceD;
                                            if(suggestionCymfData[index15]['price'] == '0.00') {
                                              cymfPriceD = "";
                                            } else {
                                              cymfPriceD ='+ ₱ ${suggestionCymfData[index15]['price']}';
                                            }
                                            if (suggestionCymfData[index15]['unit']!=null) {
                                              uomName = suggestionCymfData[index15]['unit'].toString();
                                            }

                                            return InkWell(
                                              child: Padding(
                                                padding: EdgeInsets.all(0),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [

                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [

                                                        Flexible(
                                                          fit: FlexFit.loose,
                                                          child: SizedBox(height: 35,
                                                            child: RadioListTile(
                                                              visualDensity: const VisualDensity(
                                                                horizontal: VisualDensity.minimumDensity,
                                                                vertical: VisualDensity.minimumDensity,
                                                              ),
                                                              contentPadding: EdgeInsets.all(0),
                                                              activeColor: Colors.deepOrange,
                                                              title: Transform.translate(
                                                                offset: const Offset(-10, 0),
                                                                child: Row(
                                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                  children: [
                                                                    Text('${suggestionCymfData[index15]['suggestion_name']} ', style: TextStyle(fontStyle: FontStyle.normal, fontSize: 13)),
                                                                    Text('$cymfPriceD', style: TextStyle(fontStyle: FontStyle.normal, fontSize: 13)),
                                                                  ],
                                                                ),
                                                              ),
                                                              value: index15,
                                                              groupValue: suggestionCymfDataGroupValue,
                                                              onChanged: (newValue) {
                                                                setState((){
                                                                  print(newValue);
                                                                  suggestionCymfDataGroupValue = newValue;
                                                                  suggestionIdCymf = suggestionCymfData[index15]['suggestion_id'];
                                                                  productSuggestionIdCymf = suggestionCymfData[index15]['prod_suggestion_id'];
                                                                  suggestionPriceCymf = suggestionCymfData[index15]['price'];
                                                                });
                                                              },
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                ///Type of Mission Burrito
                                Visibility(
                                  visible:suggestionTombDataVisible,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [

                                      Padding(
                                        padding: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                                        child: Text("Select Type of Mission Burrito",style: TextStyle(fontSize: 15.0,fontWeight: FontWeight.bold, color: Colors.black54),),
                                      ),

                                      Padding(
                                        padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 10.0),
                                        child: ListView.builder(
                                          physics: NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          itemCount: suggestionTombData == null ? 0 : suggestionTombData.length,
                                          itemBuilder: (BuildContext context, int index16) {

                                            String uomName = "";
                                            String tombPriceD;
                                            if(suggestionTombData[index16]['price'] == '0.00') {
                                              tombPriceD = "";
                                            } else {
                                              tombPriceD ='+ ₱ ${suggestionTombData[index16]['price']}';
                                            }
                                            if (suggestionTombData[index16]['unit']!=null) {
                                              uomName = suggestionTombData[index16]['unit'].toString();
                                            }

                                            return InkWell(
                                              child: Padding(
                                                padding: EdgeInsets.all(0),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [

                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [

                                                        Flexible(
                                                          fit: FlexFit.loose,
                                                          child: SizedBox(height: 35,
                                                            child: RadioListTile(
                                                              visualDensity: const VisualDensity(
                                                                horizontal: VisualDensity.minimumDensity,
                                                                vertical: VisualDensity.minimumDensity,
                                                              ),
                                                              contentPadding: EdgeInsets.all(0),
                                                              activeColor: Colors.deepOrange,
                                                              title: Transform.translate(
                                                                offset: const Offset(-10, 0),
                                                                child: Row(
                                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                  children: [
                                                                    Text('${suggestionTombData[index16]['suggestion_name']} ', style: TextStyle(fontStyle: FontStyle.normal, fontSize: 13)),
                                                                    Text('$tombPriceD', style: TextStyle(fontStyle: FontStyle.normal, fontSize: 13)),
                                                                  ],
                                                                ),
                                                              ),
                                                              value: index16,
                                                              groupValue: suggestionTombDataGroupValue,
                                                              onChanged: (newValue) {
                                                                setState((){
                                                                  print(newValue);
                                                                  suggestionTombDataGroupValue = newValue;
                                                                  suggestionIdTomb = suggestionTombData[index16]['suggestion_id'];
                                                                  productSuggestionIdTomb = suggestionTombData[index16]['prod_suggestion_id'];
                                                                  suggestionPriceTomb = suggestionTombData[index16]['price'];
                                                                });
                                                              },
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                ///Choice of Sweet Variant
                                Visibility(
                                  visible:suggestionCosvDataVisible,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [

                                      Padding(
                                        padding: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                                        child: Text("Select Choice of Sweet Variant",style: TextStyle(fontSize: 15.0,fontWeight: FontWeight.bold, color: Colors.black54),),
                                      ),

                                      Padding(
                                        padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 10.0),
                                        child: ListView.builder(
                                          physics: NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          itemCount: suggestionCosvData == null ? 0 : suggestionCosvData.length,
                                          itemBuilder: (BuildContext context, int index17) {

                                            String uomName = "";
                                            String cosvPriceD;
                                            if(suggestionCosvData[index17]['price'] == '0.00') {
                                              cosvPriceD = "";
                                            } else {
                                              cosvPriceD ='+ ₱ ${suggestionCosvData[index17]['price']}';
                                            }
                                            if (suggestionCosvData[index17]['unit']!=null) {
                                              uomName = suggestionCosvData[index17]['unit'].toString();
                                            }

                                            return InkWell(
                                              child: Padding(
                                                padding: EdgeInsets.all(0),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [

                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [

                                                        Flexible(
                                                          fit: FlexFit.loose,
                                                          child: SizedBox(height: 35,
                                                            child: RadioListTile(
                                                              visualDensity: const VisualDensity(
                                                                horizontal: VisualDensity.minimumDensity,
                                                                vertical: VisualDensity.minimumDensity,
                                                              ),
                                                              contentPadding: EdgeInsets.all(0),
                                                              activeColor: Colors.deepOrange,
                                                              title: Transform.translate(
                                                                offset: const Offset(-10, 0),
                                                                child: Row(
                                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                  children: [
                                                                    Text('${suggestionCosvData[index17]['suggestion_name']} ', style: TextStyle(fontStyle: FontStyle.normal, fontSize: 13)),
                                                                    Text('$cosvPriceD', style: TextStyle(fontStyle: FontStyle.normal, fontSize: 13)),
                                                                  ],
                                                                ),
                                                              ),
                                                              value: index17,
                                                              groupValue: suggestionCosvDataGroupValue,
                                                              onChanged: (newValue) {
                                                                setState((){
                                                                  print(newValue);
                                                                  suggestionCosvDataGroupValue = newValue;
                                                                  suggestionIdCosv = suggestionCosvData[index17]['suggestion_id'];
                                                                  productSuggestionIdCosv = suggestionCosvData[index17]['prod_suggestion_id'];
                                                                  suggestionPriceCosv = suggestionCosvData[index17]['price'];
                                                                });
                                                              },
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                ///Type of Pizza
                                Visibility(
                                  visible:suggestionTopDataVisible,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [

                                      Padding(
                                        padding: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                                        child: Text("Select Type of Pizza",style: TextStyle(fontSize: 15.0,fontWeight: FontWeight.bold, color: Colors.black54),),
                                      ),

                                      Padding(
                                        padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 10.0),
                                        child: ListView.builder(
                                          physics: NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          itemCount: suggestionTopData == null ? 0 : suggestionTopData.length,
                                          itemBuilder: (BuildContext context, int index18) {

                                            String uomName = "";
                                            String topPriceD;
                                            if(suggestionTopData[index18]['price'] == '0.00') {
                                              topPriceD = "";
                                            } else {
                                              topPriceD ='+ ₱ ${suggestionTopData[index18]['price']}';
                                            }
                                            if (suggestionTopData[index18]['unit']!=null) {
                                              uomName = suggestionTopData[index18]['unit'].toString();
                                            }

                                            return InkWell(
                                              child: Padding(
                                                padding: EdgeInsets.all(0),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [

                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [

                                                        Flexible(
                                                          fit: FlexFit.loose,
                                                          child: SizedBox(height: 35,
                                                            child: RadioListTile(
                                                              visualDensity: const VisualDensity(
                                                                horizontal: VisualDensity.minimumDensity,
                                                                vertical: VisualDensity.minimumDensity,
                                                              ),
                                                              contentPadding: EdgeInsets.all(0),
                                                              activeColor: Colors.deepOrange,
                                                              title: Transform.translate(
                                                                offset: const Offset(-10, 0),
                                                                child: Row(
                                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                  children: [
                                                                    Text('${suggestionTopData[index18]['suggestion_name']} ', style: TextStyle(fontStyle: FontStyle.normal, fontSize: 13)),
                                                                    Text('$topPriceD', style: TextStyle(fontStyle: FontStyle.normal, fontSize: 13)),
                                                                  ],
                                                                ),
                                                              ),
                                                              value: index18,
                                                              groupValue: suggestionTopDataGroupValue,
                                                              onChanged: (newValue) {
                                                                setState((){
                                                                  print(newValue);
                                                                  suggestionTopDataGroupValue = newValue;
                                                                  suggestionIdTop = suggestionTopData[index18]['suggestion_id'];
                                                                  productSuggestionIdTop = suggestionTopData[index18]['prod_suggestion_id'];
                                                                  suggestionPriceTop = suggestionTopData[index18]['price'];
                                                                });
                                                              },
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                ///Type of Cruncy Wrap
                                Visibility(
                                  visible:suggestionTocwDataVisible,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [

                                      Padding(
                                        padding: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                                        child: Text("Select Type of Crunchy Wrap",style: TextStyle(fontSize: 15.0,fontWeight: FontWeight.bold, color: Colors.black54),),
                                      ),

                                      Padding(
                                        padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 10.0),
                                        child: ListView.builder(
                                          physics: NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          itemCount: suggestionTocwData == null ? 0 : suggestionTocwData.length,
                                          itemBuilder: (BuildContext context, int index19) {

                                            String uomName = "";
                                            String topPriceD;
                                            if(suggestionTocwData[index19]['price'] == '0.00') {
                                              topPriceD = "";
                                            } else {
                                              topPriceD ='+ ₱ ${suggestionTocwData[index19]['price']}';
                                            }
                                            if (suggestionTocwData[index19]['unit']!=null) {
                                              uomName = suggestionTocwData[index19]['unit'].toString();
                                            }

                                            return InkWell(
                                              child: Padding(
                                                padding: EdgeInsets.all(0),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [

                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [

                                                        Flexible(
                                                          fit: FlexFit.loose,
                                                          child: SizedBox(height: 35,
                                                            child: RadioListTile(
                                                              visualDensity: const VisualDensity(
                                                                horizontal: VisualDensity.minimumDensity,
                                                                vertical: VisualDensity.minimumDensity,
                                                              ),
                                                              contentPadding: EdgeInsets.all(0),
                                                              activeColor: Colors.deepOrange,
                                                              title: Transform.translate(
                                                                offset: const Offset(-10, 0),
                                                                child: Row(
                                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                  children: [
                                                                    Text('${suggestionTocwData[index19]['suggestion_name']} ', style: TextStyle(fontStyle: FontStyle.normal, fontSize: 13)),
                                                                    Text('$topPriceD', style: TextStyle(fontStyle: FontStyle.normal, fontSize: 13)),
                                                                  ],
                                                                ),
                                                              ),
                                                              value: index19,
                                                              groupValue: suggestionTocwDataGroupValue,
                                                              onChanged: (newValue) {
                                                                setState((){
                                                                  print(newValue);
                                                                  suggestionTocwDataGroupValue = newValue;
                                                                  suggestionIdTocw = suggestionTocwData[index19]['suggestion_id'];
                                                                  productSuggestionIdTocw = suggestionTocwData[index19]['prod_suggestion_id'];
                                                                  suggestionPriceTocw = suggestionTocwData[index19]['price'];
                                                                });
                                                              },
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                ///Type of --> or nameless
                                Visibility(
                                  visible:suggestionNamelessDataVisible,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [

                                      Padding(
                                        padding: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                                        child: Text("Select -->",style: TextStyle(fontSize: 15.0,fontWeight: FontWeight.bold, color: Colors.black54),),
                                      ),

                                      Padding(
                                        padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 10.0),
                                        child: ListView.builder(
                                          physics: NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          itemCount: suggestionNamelessData == null ? 0 : suggestionNamelessData.length,
                                          itemBuilder: (BuildContext context, int index20) {

                                            String uomName = "";
                                            String topPriceD;
                                            if(suggestionNamelessData[index20]['price'] == '0.00') {
                                              topPriceD = "";
                                            } else {
                                              topPriceD ='+ ₱ ${suggestionNamelessData[index20]['price']}';
                                            }
                                            if (suggestionNamelessData[index20]['unit']!=null) {
                                              uomName = suggestionNamelessData[index20]['unit'].toString();
                                            }

                                            return InkWell(
                                              child: Padding(
                                                padding: EdgeInsets.all(0),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [

                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [

                                                        Flexible(
                                                          fit: FlexFit.loose,
                                                          child: SizedBox(height: 35,
                                                            child: RadioListTile(
                                                              visualDensity: const VisualDensity(
                                                                horizontal: VisualDensity.minimumDensity,
                                                                vertical: VisualDensity.minimumDensity,
                                                              ),
                                                              contentPadding: EdgeInsets.all(0),
                                                              activeColor: Colors.deepOrange,
                                                              title: Transform.translate(
                                                                offset: const Offset(-10, 0),
                                                                child: Row(
                                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                  children: [
                                                                    Text('${suggestionNamelessData[index20]['suggestion_name']} ', style: TextStyle(fontStyle: FontStyle.normal, fontSize: 13)),
                                                                    Text('$topPriceD', style: TextStyle(fontStyle: FontStyle.normal, fontSize: 13)),
                                                                  ],
                                                                ),
                                                              ),
                                                              value: index20,
                                                              groupValue: suggestionNamelessDataGroupValue,
                                                              onChanged: (newValue) {
                                                                setState((){
                                                                  print(newValue);
                                                                  suggestionNamelessDataGroupValue = newValue;
                                                                  suggestionIdNameless = suggestionNamelessData[index20]['suggestion_id'];
                                                                  productSuggestionIdNameless = suggestionNamelessData[index20]['prod_suggestion_id'];
                                                                  suggestionPriceNameless = suggestionNamelessData[index20]['price'];
                                                                });
                                                              },
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                ///choices Drinks
                                Visibility(
                                  visible:choicesDrinksVisible,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [

                                      Padding(
                                          padding: EdgeInsets.fromLTRB(10.0, 10.0, 0.0, 0.0),
                                          child: Column(
                                            children: [

                                              Text("1-pc Choice of Drinks",style: TextStyle(fontSize: 15.0,fontWeight: FontWeight.bold, color: Colors.black54)),
                                              Text("Select 1",style: TextStyle(fontSize: 14.0,fontWeight: FontWeight.bold, color: Colors.black54)),
                                            ],
                                          )
                                      ),
                                      Padding(
                                        padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 10.0),
                                        child: ListView.builder(
                                            physics: NeverScrollableScrollPhysics(),
                                            shrinkWrap: true,
                                            itemCount:choicesDrinksData == null ? 0 : choicesDrinksData.length,
                                            itemBuilder: (BuildContext context, int index6) {
                                              String uomName = "";
                                              String sidePrice;
                                              if (choicesDrinksData[index6]['addon_price'] == '0.00') {
                                                sidePrice = "";
                                              } else {
                                                sidePrice ='+ ₱ ${choicesDrinksData[index6]['addon_price']}';
                                              }
                                              if (choicesDrinksData[index6]['unit'] != null) {
                                                uomName = choicesDrinksData[index6]['unit'].toString();
                                              }
                                              return Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [

                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [

                                                      Flexible(
                                                        fit: FlexFit.loose,
                                                        child: SizedBox(height: 35,
                                                          child: RadioListTile(
                                                            visualDensity: const VisualDensity(
                                                              horizontal: VisualDensity.minimumDensity,
                                                              vertical: VisualDensity.minimumDensity,
                                                            ),
                                                            contentPadding: EdgeInsets.all(0),
                                                            activeColor: Colors.deepOrange,
                                                            title:  Transform.translate(
                                                              offset: const Offset(-10, 0),
                                                              child: Row(
                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                children: [

                                                                  Expanded(
                                                                    child: Text('${choicesDrinksData[index6]['sub_productname']}  $uomName', overflow: TextOverflow.ellipsis, style: TextStyle(fontStyle: FontStyle.normal, fontSize: 13)),),
                                                                  Text('$sidePrice', style: TextStyle(fontStyle: FontStyle.normal, fontSize: 13)),
                                                                ],
                                                              ),
                                                            ),
                                                            value: index6,
                                                            groupValue: choiceDrinksGroupValue,
                                                            onChanged: (newValue) {
                                                              setState((){
                                                                choiceDrinksGroupValue = newValue;
                                                                choiceUomIdDrinks = choicesDrinksData[index6]['uom_id'];
                                                                choiceIdDrinks = choicesDrinksData[index6]['sub_productid'];
                                                                choicePriceDrinks = choicesDrinksData[index6]['addon_price'];
                                                                print(choiceIdDrinks);
                                                                print(choiceUomIdDrinks);
                                                              });
                                                            },
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              );
                                            }
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                ///choices Fries
                                Visibility(
                                  visible:choicesFriesVisible,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [

                                      Padding(
                                        padding: EdgeInsets.fromLTRB(10.0, 10.0, 0.0, 0.0),
                                        child: Column(
                                          children: [
                                            Text("1-pc Choice of Fries",style: TextStyle(fontSize: 16.0,fontWeight: FontWeight.bold, color: Colors.black54),),
                                            Text("Select 1",style: TextStyle(fontSize: 15.0,fontWeight: FontWeight.bold, color: Colors.black54),),
                                          ],
                                        ),
                                      ),

                                      Padding(
                                        padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 10.0),
                                        child: ListView.builder(
                                            physics: NeverScrollableScrollPhysics(),
                                            shrinkWrap: true,
                                            itemCount:choicesFriesData == null ? 0 : choicesFriesData.length,
                                            itemBuilder: (BuildContext context, int index7) {
                                              String uomName = "";
                                              String sidePrice;
                                              if (choicesFriesData[index7]['addon_price'] == '0.00') {
                                                sidePrice = "";
                                              } else {
                                                sidePrice ='+ ₱ ${choicesFriesData[index7]['addon_price']}';
                                              }
                                              if (choicesFriesData[index7]['unit'] != null) {
                                                uomName = choicesFriesData[index7]['unit'].toString();
                                              }
                                              return Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [

                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [

                                                      Flexible(
                                                        fit: FlexFit.loose,
                                                        child: SizedBox(height: 35,
                                                          child: RadioListTile(
                                                            visualDensity: const VisualDensity(
                                                              horizontal: VisualDensity.minimumDensity,
                                                              vertical: VisualDensity.minimumDensity,
                                                            ),
                                                            contentPadding: EdgeInsets.all(0),
                                                            activeColor: Colors.deepOrange,
                                                            title:  Transform.translate(
                                                              offset: const Offset(-10, 0),
                                                              child: Row(
                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                children: [

                                                                  Expanded(
                                                                    child: Text('${choicesFriesData[index7]['sub_productname']} $uomName', overflow: TextOverflow.ellipsis, style: TextStyle(fontStyle: FontStyle.normal, fontSize: 13)),
                                                                  ),
                                                                  Text('$sidePrice', style: TextStyle(fontStyle: FontStyle.normal, fontSize: 13)),
                                                                ],
                                                              ),
                                                            ),
                                                            value: index7,
                                                            groupValue: choiceFriesGroupValue,
                                                            onChanged: (newValue) {
                                                              setState((){
                                                                choiceFriesGroupValue = newValue;
                                                                choiceUomIdFries = choicesFriesData[index7]['uom_id'];
                                                                choiceIdFries = choicesFriesData[index7]['sub_productid'];
                                                                choicePriceFries = choicesFriesData[index7]['addon_price'];
                                                                print(choiceUomIdFries);
                                                                print(choiceIdFries);
                                                              });
                                                            },
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              );
                                            }
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                ///choices Sides
                                Visibility(
                                  visible:choicesSidesVisible,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [

                                      Padding(
                                          padding: EdgeInsets.fromLTRB(10.0, 10.0, 0.0, 0.0),
                                          child: Column(
                                            children: [
                                              Text("1-pc Choice of Sides",style: TextStyle(fontSize: 16.0,fontWeight: FontWeight.bold, color: Colors.black54),),
                                              Text("Select 1",style: TextStyle(fontSize: 15.0,fontWeight: FontWeight.bold, color: Colors.black54),),
                                            ],
                                          )
                                      ),

                                      Padding(
                                        padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 10.0),
                                        child: ListView.builder(
                                            physics: NeverScrollableScrollPhysics(),
                                            shrinkWrap: true,
                                            itemCount:choicesSidesData == null ? 0 : choicesSidesData.length,
                                            itemBuilder: (BuildContext context, int index8) {
                                              String uomName = "";
                                              String sidePrice;
                                              if (choicesSidesData[index8]['addon_price'] == '0.00') {
                                                sidePrice = "";
                                              } else {
                                                sidePrice ='+ ₱ ${choicesSidesData[index8]['addon_price']}';
                                              }
                                              if (choicesSidesData[index8]['unit']!=null) {
                                                uomName = choicesSidesData[index8]['unit'].toString();
                                              }
                                              return Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [

                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [

                                                      Flexible(
                                                          fit: FlexFit.loose,
                                                          child: SizedBox(height: 35,
                                                              child: RadioListTile(
                                                                visualDensity: const VisualDensity(
                                                                  horizontal: VisualDensity.minimumDensity,
                                                                  vertical: VisualDensity.minimumDensity,
                                                                ),
                                                                contentPadding: EdgeInsets.all(0),
                                                                activeColor: Colors.deepOrange,
                                                                title:  Transform.translate(
                                                                  offset: const Offset(-10, 0),
                                                                  child: Row(
                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                    children: [

                                                                      Expanded(
                                                                        child: Text('${choicesSidesData[index8]['sub_productname']} $uomName', overflow: TextOverflow.ellipsis, style: TextStyle(fontStyle: FontStyle.normal, fontSize: 13)),
                                                                      ),
                                                                      Text('$sidePrice', style: TextStyle(fontStyle: FontStyle.normal, fontSize: 13)),
                                                                    ],
                                                                  ),
                                                                ),
                                                                value: index8,
                                                                groupValue: choiceSidesGroupValue,
                                                                onChanged: (newValue1) {
                                                                  setState((){
                                                                    choiceSidesGroupValue = newValue1;
                                                                    choiceUomIdSides = choicesSidesData[index8]['uom_id'];
                                                                    choiceIdSides = choicesSidesData[index8]['sub_productid'];
                                                                    choicePriceSides = choicesSidesData[index8]['addon_price'];
                                                                    print('$choiceUomIdSides');
                                                                    print('$choiceIdSides');
                                                                  });
                                                                },
                                                              )
                                                          )
                                                      ),
                                                    ],
                                                  )
                                                ],
                                              );
                                            }
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                ///addon Drinks
                                Visibility(
                                  visible:addonDrinksDataVisible,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [

                                      Padding(
                                        padding: EdgeInsets.fromLTRB(10.0, 10.0, 5.0, 0.0),
                                        child: Text("Add-on Drink(s)",style: TextStyle(fontSize: 16.0,fontWeight: FontWeight.bold, color: Colors.black54),),
                                      ),

                                      Padding(
                                        padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 10.0),
                                        child: ListView.builder(
                                            physics: NeverScrollableScrollPhysics(),
                                            shrinkWrap: true,
                                            itemCount:addonDrinksData == null ? 0 : addonDrinksData.length,
                                            itemBuilder: (BuildContext context, int index9) {
                                              String uomName = "";
                                              String addonPrice = addonDrinksData[index9]['addon_price'];
                                              if (addonPrice == '0.00') {
                                                addonPrice = "";
                                              }
                                              if (addonDrinksData[index9]['unit'] != null) {
                                                uomName = addonDrinksData[index9]['unit'];
                                              }
                                              side1.add(false);
                                              return Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [

                                                  SizedBox(height: 35,
                                                    child: CheckboxListTile(
                                                      visualDensity: const VisualDensity(
                                                        horizontal: VisualDensity.minimumDensity,
                                                        vertical: VisualDensity.minimumDensity,
                                                      ),
                                                      contentPadding: EdgeInsets.all(0),
                                                      activeColor: Colors.deepOrange,
                                                      title: Transform.translate(
                                                        offset: const Offset(-10, 0),
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            Text('${addonDrinksData[index9]['sub_productname']} $uomName', style: TextStyle(fontStyle: FontStyle.normal, fontSize: 13)),
                                                            Text('+ ₱ $addonPrice', style: TextStyle(fontStyle: FontStyle.normal, fontSize: 13))
                                                          ],
                                                        ),
                                                      ),
                                                      value: side1[index9],
                                                      onChanged: (bool value1){
                                                        setState(() {
                                                          side1[index9] = value1;
                                                          // selectedSideItems.clear();
                                                          // selectedSideItemsUom.clear();
                                                          if (value1) {
                                                            selectedSideOnPrice.add(addonDrinksData[index9]['addon_price']);
                                                            selectedSideItems.add(addonDrinksData[index9]['sub_productid']);
                                                            selectedSideItemsUom.add(addonDrinksData[index9]['uom_id']);
                                                            selectedSideSides.add(addonDrinksData[index9]['addon_sides']);
                                                            selectedSideDessert.add(addonDrinksData[index9]['addon_dessert']);
                                                            selectedSideDrinks.add(addonDrinksData[index9]['addon_drinks']);

                                                          } else {
                                                            selectedSideOnPrice.remove(addonDrinksData[index9]['addon_price']);
                                                            selectedSideItems.remove(addonDrinksData[index9]['sub_productid']);
                                                            selectedSideItemsUom.remove(addonDrinksData[index9]['uom_id']);
                                                            selectedSideSides.remove(addonDrinksData[index9]['addon_sides']);
                                                            selectedSideDessert.remove(addonDrinksData[index9]['addon_dessert']);
                                                            selectedSideDrinks.remove(addonDrinksData[index9]['addon_drinks']);

                                                          }
                                                          print(selectedSideSides);
                                                        });
                                                      },
                                                      controlAffinity: ListTileControlAffinity.leading,
                                                    ),
                                                  ),
                                                ],
                                              );
                                            }
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                ///addon Desserts
                                Visibility(
                                  visible:addonDessertDataVisible,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [

                                      Padding(
                                        padding: EdgeInsets.fromLTRB(10.0, 10.0, 0.0, 0.0),
                                        child: Text("Add-on Dessert(s)",style: TextStyle(fontSize: 16.0,fontWeight: FontWeight.bold, color: Colors.black54),),
                                      ),

                                      Padding(
                                        padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 10.0),
                                        child: ListView.builder(
                                            physics: NeverScrollableScrollPhysics(),
                                            shrinkWrap: true,
                                            itemCount:addonDessertData == null ? 0 : addonDessertData.length,
                                            itemBuilder: (BuildContext context, int index10) {
                                              String uomName = "";
                                              String addonPrice = addonDessertData[index10]['addon_price'];
                                              if(addonPrice == '0.00'){
                                                addonPrice = "";
                                              }
                                              if(addonDessertData[index10]['unit']!=null){
                                                uomName = addonDessertData[index10]['unit'];
                                              }
                                              side2.add(false);
                                              return Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [

                                                  SizedBox(height: 35,
                                                    child:
                                                    CheckboxListTile(
                                                      visualDensity: const VisualDensity(
                                                        horizontal: VisualDensity.minimumDensity,
                                                        vertical: VisualDensity.minimumDensity,
                                                      ),
                                                      contentPadding: EdgeInsets.all(0),
                                                      activeColor: Colors.deepOrange,
                                                      title: Transform.translate(
                                                        offset: const Offset(-10, 0),
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [

                                                            Text('${addonDessertData[index10]['sub_productname']} $uomName', style: TextStyle(fontStyle: FontStyle.normal, fontSize: 13)),
                                                            Text('+ ₱ $addonPrice', style: TextStyle(fontStyle: FontStyle.normal, fontSize: 13))
                                                          ],
                                                        ),
                                                      ),
                                                      value: side2[index10],
                                                      onChanged: (bool value2){
                                                        setState(() {
                                                          side2[index10] = value2;
                                                          // selectedSideItems.clear();
                                                          // selectedSideItemsUom.clear();
                                                          if (value2) {
                                                            selectedSideOnPrice.add(addonDessertData[index10]['addon_price']);
                                                            selectedSideItems.add(addonDessertData[index10]['sub_productid']);
                                                            selectedSideItemsUom.add(addonDessertData[index10]['uom_id']);
                                                            selectedSideSides.add(addonDessertData[index10]['addon_sides']);
                                                            selectedSideDessert.add(addonDessertData[index10]['addon_dessert']);
                                                            selectedSideDrinks.add(addonDessertData[index10]['addon_Drinks']);

                                                          } else {
                                                            selectedSideOnPrice.remove(addonDessertData[index10]['addon_price']);
                                                            selectedSideItems.remove(addonDessertData[index10]['sub_productid']);
                                                            selectedSideItemsUom.remove(addonDessertData[index10]['uom_id']);
                                                            selectedSideSides.remove(addonDessertData[index10]['addon_sides']);
                                                            selectedSideDessert.remove(addonDessertData[index10]['addon_dessert']);
                                                            selectedSideDrinks.remove(addonDessertData[index10]['addon_Drinks']);
                                                          }
                                                          print(selectedSideSides);
                                                        });
                                                      },
                                                      controlAffinity: ListTileControlAffinity.leading,
                                                    ),
                                                  ),
                                                ],
                                              );
                                            }
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                ///addon Sides
                                Visibility(
                                  visible:addonSidesDataVisible,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [

                                      Padding(
                                        padding: EdgeInsets.fromLTRB(10.0, 10.0, 0.0, 0.0),
                                        child: Text("Add-on Side(s)",style: TextStyle(fontSize: 16.0,fontWeight: FontWeight.bold, color: Colors.black54),),
                                      ),

                                      Padding(
                                        padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 10.0),
                                        child: ListView.builder(
                                            physics: NeverScrollableScrollPhysics(),
                                            shrinkWrap: true,
                                            itemCount:addonSidesData == null ? 0 : addonSidesData.length,
                                            itemBuilder: (BuildContext context, int index11) {
                                              String uomName = "";
                                              String addonPrice = addonSidesData[index11]['addon_price'];
                                              if(addonPrice == '0.00'){
                                                addonPrice = "";
                                              }
                                              if(addonSidesData[index11]['unit']!=null){
                                                uomName = addonSidesData[index11]['unit'];
                                              }
                                              side3.add(false);
                                              return Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [

                                                  SizedBox(height: 35,
                                                    child: CheckboxListTile(
                                                      visualDensity: const VisualDensity(
                                                        horizontal: VisualDensity.minimumDensity,
                                                        vertical: VisualDensity.minimumDensity,
                                                      ),
                                                      contentPadding: EdgeInsets.all(0),
                                                      activeColor: Colors.deepOrange,
                                                      title: Transform.translate(
                                                        offset: const Offset(-10, 0),
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [

                                                            Text('${addonSidesData[index11]['sub_productname']} $uomName', style: TextStyle(fontStyle: FontStyle.normal, fontSize: 13)),
                                                            Text('+ ₱ $addonPrice', style: TextStyle(fontStyle: FontStyle.normal, fontSize: 13))
                                                          ],
                                                        ),
                                                      ),
                                                      value: side3[index11],
                                                      onChanged: (bool value3){
                                                        setState(() {
                                                          side3[index11] = value3;
                                                          if (value3) {
                                                            selectedSideOnPrice.add(addonSidesData[index11]['addon_price']);
                                                            selectedSideItems.add(addonSidesData[index11]['sub_productid']);
                                                            selectedSideItemsUom.add(addonSidesData[index11]['uom_id']);
                                                            selectedSideSides.add(addonSidesData[index11]['addon_sides']);
                                                            selectedSideDessert.add(addonSidesData[index11]['addon_dessert']);
                                                            selectedSideDrinks.add(addonSidesData[index11]['addon_Drinks']);

                                                          } else {
                                                            selectedSideOnPrice.remove(addonSidesData[index11]['addon_price']);
                                                            selectedSideItems.remove(addonSidesData[index11]['sub_productid']);
                                                            selectedSideItemsUom.remove(addonSidesData[index11]['uom_id']);
                                                            selectedSideSides.remove(addonSidesData[index11]['addon_sides']);
                                                            selectedSideDessert.remove(addonSidesData[index11]['addon_dessert']);
                                                            selectedSideDrinks.remove(addonSidesData[index11]['addon_Drinks']);
                                                          }
                                                          print(selectedSideSides);
                                                          print(selectedSideItemsUom);
                                                        });
                                                      },
                                                      controlAffinity: ListTileControlAffinity.leading,
                                                    ),
                                                  ),
                                                ],
                                              );
                                            }
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
                  child:Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [

                      TextButton(
                        onPressed: _counter == 1 ? null : _decrementCounter,
                        child: new Text('-',style: TextStyle(fontSize: 20,color: Colors.deepOrange,),),
                      ),

                      Padding(
                        padding: EdgeInsets.fromLTRB(0, 0, 5, 0),
                      ),

                      Text(_counter.toString()),

                      Padding(
                        padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
                      ),

                      TextButton(
                        onPressed: _counter == 999 ? null : _incrementCounter,
                        child: new Text('+',style: TextStyle(fontSize: 20,color: Colors.deepOrange,),),
                      ),

                      Padding(
                        padding: EdgeInsets.fromLTRB(5, 20, 5, 5),
                      ),

                      Flexible(
                        child: SleekButton(
                          onTap: () async{

                            if (grams == true) {
                              if (amountPerGram.text.isEmpty){
                                print('dli pa pwede');
                                CoolAlert.show(
                                  context: context,
                                  type: CoolAlertType.error,
                                  text: "Please enter amount",
                                  confirmBtnColor: Colors.deepOrangeAccent,
                                  backgroundColor: Colors.deepOrangeAccent,
                                  barrierDismissible: false,
                                  confirmBtnText: 'Okay',
                                  onConfirmBtnTap: () async {
                                    Navigator.of(context, rootNavigator: true).pop();
                                  },
                                );
                              } else if (gramInput < defaultGram){
                                CoolAlert.show(
                                  context: context,
                                  type: CoolAlertType.error,
                                  text: "Enter at least a minimum of 100 grams",
                                  confirmBtnColor: Colors.deepOrangeAccent,
                                  backgroundColor: Colors.deepOrangeAccent,
                                  barrierDismissible: false,
                                  confirmBtnText: 'Okay',
                                  onConfirmBtnTap: () async {
                                    Navigator.of(context, rootNavigator: true).pop();
                                  },
                                );
                              } else {
                                measurement = amountPerGram.text;
                                print('pwede kaayo');
                                addToCart();
                              }
                            } else {
                              addToCart();
                            }
                            print(selectedSideOnPrice);
                            print(selectedSideItems);
                            print(selectedSideItemsUom);
                          },
                          style: SleekButtonStyle.flat(
                            color: Colors.deepOrange,
                            inverted: false,
                            rounded: true,
                            size: SleekButtonSize.big,
                            context: context,
                          ),
                          child: Center(
                            child:Text("ADD TO CART", style:
                            TextStyle(
                              fontStyle: FontStyle.normal,
                              fontWeight: FontWeight.bold,
                              fontSize: 13.0,
                              shadows: [
                                Shadow(
                                  blurRadius: 1.0,
                                  color: Colors.black54,
                                  offset: Offset(1.0, 1.0),
                                ),
                              ],
                            ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Route _signIn() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => CreateAccountSignIn(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var begin = Offset(0.0, 1.0);
      var end = Offset.zero;
      var curve = Curves.decelerate;
      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}

Route _search() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => Search(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var begin = Offset(1.0, 0.0);
      var end = Offset.zero;
      var curve = Curves.decelerate;
      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}