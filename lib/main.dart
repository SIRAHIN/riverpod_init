import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod_practice/dummy_future_data.dart';
import 'package:riverpod_practice/firebase_analytics_service.dart';
import 'package:riverpod_practice/firebase_options.dart';
import 'package:riverpod_practice/injection.dart';
import 'package:riverpod_practice/models/auth_credential.dart';
import 'package:riverpod_practice/registration_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  configureDependencies();

  await Hive.initFlutter();

  Hive.registerAdapter(AuthCredentialAdapter());

  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: RegistrationScreen(),
      navigatorObservers: [FirebaseAnalyticsService().getAnalyticsObserver()],
    );
  }
}

// For static data
final Provider staticStringProvider = Provider<String>((ref) {
  return 'Hello, World!';
});

// For counter change state
final StateProvider<int> counterProvider = StateProvider<int>((ref) {
  return 0;
});

// For toggle switch change state
final StateProvider<bool> toggleSwitchProvider = StateProvider<bool>((ref) {
  return false;
});

// For slider change state
final StateProvider<double> sliderProvider = StateProvider<double>((ref) {
  return 0.0;
});

// For Future provider
final FutureProvider<String> dummyWeatherProvider = FutureProvider<String>(
  (ref) { 
    
   return fetchWeather();
  },
);

class DummyWeatherState {}
class LoadingState extends DummyWeatherState{}
class LoadedState extends DummyWeatherState{
  final String data;
  LoadedState(this.data);
}
class ErrorState extends DummyWeatherState{}
class InitialState extends DummyWeatherState{}

class DummyWeatherNotifier extends StateNotifier<DummyWeatherState>{
  DummyWeatherNotifier() : super(InitialState());
  
  void fetchWeatherData()async {
    state = LoadingState();
    final response = await fetchWeather();
    state = LoadedState(response);
  }
}

final DummyWatherProvider = StateNotifierProvider<DummyWeatherNotifier, DummyWeatherState>((ref) => DummyWeatherNotifier(),);

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();


    // You can use ref here ✅
    Future.microtask(() {
      ref.read(DummyWatherProvider.notifier).fetchWeatherData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dummyWeatherState = ref.watch(DummyWatherProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text('Counter'),
        actions: [
          IconButton(
            onPressed: () {
              ref.read(counterProvider.notifier).state = 0;
              ref.read(toggleSwitchProvider.notifier).state = false;
              ref.read(sliderProvider.notifier).state = 0.0;

              FirebaseAnalyticsService().logEvent(
                  eventName: "counter_reset_event_ios",
                  params: {
                    'event': 'Ios reset count event',
                    'eventId': '1002'
                  });
            },
            icon: Icon(Icons.refresh),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 20,
          children: [
            // Text(ref.watch(counterProvider).toString()),
            // ElevatedButton(
            //   onPressed: () {
            //     ref.read(counterProvider.notifier).state++;
            //   },
            //   child: Text('Increment'),
            // ),
            // ElevatedButton(
            //   onPressed: () {
            //     ref.read(counterProvider.notifier).state--;
            //   },
            //   child: Text('Decrement'),
            // ),

            // Switch(value: ref.watch(toggleSwitchProvider), onChanged: (value) {
            //   ref.read(toggleSwitchProvider.notifier).state = value;
            // },),

            // Slider( min: 0.0, max: 1.0, value: ref.watch(sliderProvider), onChanged: (value) {
            //   ref.read(sliderProvider.notifier).state = value;
            //   if(value > 0.5) {
            //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Slider value is greater than 0.5')));
            //   }
            // },)

            // ====== Complex State Management ======
            // Padding(
            //   padding: const EdgeInsets.all(8.0),
            //   child: TextField(
            //     onSubmitted: (value) {
            //       ref.read(todoNotifierProvider.notifier).addTodo(value);
            //     },
            //   ),
            // ),
            // Padding(
            //   padding: const EdgeInsets.all(8.0),
            //   child: ListView.builder(
            //     shrinkWrap: true,
            //     physics: NeverScrollableScrollPhysics(),
            //     itemCount: ref.watch(todoNotifierProvider).length,
            //     itemBuilder: (context, index) {
            //       return ListTile(
            //         title: Text(ref.watch(todoNotifierProvider)[index].title),
            //         trailing: Row(
            //           mainAxisSize: MainAxisSize.min,
            //           children: [
            //             IconButton(
            //               onPressed: () {
            //                 ref
            //                     .read(todoNotifierProvider.notifier)
            //                     .delete(index);
            //               },
            //               icon: Icon(Icons.delete),
            //             ),
            //             IconButton(
            //               onPressed: () {
            //                 showModalBottomSheet(
            //                   context: context,
            //                   builder: (context) {
            //                     TextEditingController textEditingController =
            //                         TextEditingController(
            //                             text: ref
            //                                 .watch(todoNotifierProvider)[index]
            //                                 .title);
            //                     return Container(
            //                       height: 400,
            //                       color: Colors.amber,
            //                       child: TextField(
            //                         controller: textEditingController,
            //                         onSubmitted: (value) {
            //                           ref
            //                               .read(todoNotifierProvider.notifier)
            //                               .updateTitle(index,
            //                                   updateTitle: value);
            //                           Navigator.pop(context);
            //                         },
            //                       ),
            //                     );
            //                   },
            //                 );
            //               },
            //               icon: Icon(Icons.update),
            //             ),
            //           ],
            //         ),
            //       );
            //     },
            //   ),
            // )

            // Expanded(
            //   child: ListView.builder(
            //     itemCount: groceryData.length,
            //     itemBuilder: (context, index) {
            //       final singleItem = groceryData[index];
            //       return ListTile(
            //         title: Text(singleItem.itemName),
            //         subtitle: Text(singleItem.itemPrice.toString()),
            //         trailing: ref
            //                     .watch(shoppingCartNotifierProdiver)[index]
            //                     .itemQty <
            //                 1
            //             ? TextButton(
            //                 onPressed: () {
            //                   ref
            //                       .read(shoppingCartNotifierProdiver.notifier)
            //                       .addToCart(singleItem);
            //                 },
            //                 child: Text("Add To Cart"))
            //             : Row(
            //                 mainAxisSize: MainAxisSize.min,
            //                 children: [
            //                   IconButton(
            //                       onPressed: () {
            //                         ref
            //                             .read(shoppingCartNotifierProdiver
            //                                 .notifier)
            //                             .addToCart(singleItem);
            //                       },
            //                       icon: Icon(Icons.add)),
            //                   Text(
            //                       "${ref.watch(shoppingCartNotifierProdiver)[index].itemQty}"),
            //                   IconButton(
            //                       onPressed: () {
            //                         ref
            //                             .read(shoppingCartNotifierProdiver
            //                                 .notifier)
            //                             .removeFromCart(singleItem);
            //                       },
            //                       icon: Icon(Icons.remove)),
            //                 ],
            //               ),
            //       );
            //     },
            //   ),
            // ),

            // Expanded(
            //     child: Text(
            //         "Total Amount : ${ref.watch(shoppingCartNotifierProdiver.notifier).getTotal()}"))

            // Select Color and Size \\
            // Expanded(
            //   child: ListView(
            //     shrinkWrap: true,
            //     scrollDirection: Axis.horizontal,
            //     children: [
            //       GestureDetector(
            //         onTap: () {
            //          ref.read(colorChoose.notifier).state = SelectedColor.Red;
            //          print(ref.read(colorChoose.notifier).state == SelectedColor.Red);
            //         },
            //         child: Container(
            //           height: 30,
            //           width: 30,
            //           decoration: BoxDecoration(
            //               border: ref.watch(colorChoose)  ==
            //                       SelectedColor.Red
            //                   ? Border.all(color: Colors.green, width: 4)
            //                   : null,
            //               shape: BoxShape.circle,
            //               color: Colors.red),
            //         ),
            //       ),
            //       SizedBox(
            //         width: 10,
            //       ),
            //       GestureDetector(
            //         onTap: () {
            //           ref.read(colorChoose.notifier).state = SelectedColor.Yellow;
            //         },
            //         child: Container(
            //           height: 30,
            //           width: 30,
            //           decoration: BoxDecoration(
            //               border: ref.watch(colorChoose)  ==
            //                       SelectedColor.Yellow
            //                   ? Border.all(color: Colors.green, width: 4)
            //                   : null,
            //               shape: BoxShape.circle,
            //               color: Colors.yellow),
            //         ),
            //       ),
            //       SizedBox(
            //         width: 10,
            //       ),
            //       GestureDetector(
            //         onTap: () {
            //           ref.read(colorChoose.notifier).state = SelectedColor.Black;
            //         },
            //         child: Container(
            //           height: 30,
            //           width: 30,
            //           decoration: BoxDecoration(
            //               border: ref.watch(colorChoose)  ==
            //                       SelectedColor.Black
            //                   ? Border.all(color: Colors.green, width: 4)
            //                   : null,
            //               shape: BoxShape.circle,
            //               color: Colors.black),
            //         ),
            //       ),
            //     ],
            //   ),
            // ),

            // Size Select From List \\
            // SizedBox(
            //   height: 100,
            //   width: double.maxFinite,
            //   child: ListView.builder(
            //     shrinkWrap: true,
            //     scrollDirection: Axis.horizontal,
            //     itemCount: sizeChart.length,
            //     itemBuilder: (context, index) {
            //       final singleItem = sizeChart[index];
            //       return GestureDetector(
            //         onTap: () {
            //           ref.read(selectedSizeIndex.notifier).state = index;
            //           print(singleItem);
            //         },
            //         child: Container(
            //           margin: EdgeInsets.all(10),
            //           alignment: Alignment.center,
            //           height: 40,
            //           width: 40,
            //           decoration: BoxDecoration(
            //             shape: BoxShape.circle,
            //             color: ref.watch(selectedSizeIndex) == index
            //                 ? Colors.amber
            //                 : Colors.grey,
            //           ),
            //           child: Text(singleItem),
            //         ),
            //       );
            //     },
            //   ),
            // ),

            if(dummyWeatherState is InitialState)
               Center(child: Text("No Data")),
            if(dummyWeatherState is LoadingState)
               Center(child: CircularProgressIndicator()),
            if(dummyWeatherState is LoadedState)
              Center(child: Text(dummyWeatherState.toString()))   

          ],
        ),
      ),
    );
  }
}

class TodoModel {
  final String title;
  final bool isDone;
  TodoModel({required this.title, required this.isDone});
}

class TodoNotifier extends Notifier<List<TodoModel>> {
  @override
  List<TodoModel> build() {
    return [];
  }

  void addTodo(String title) {
    state = [...state, TodoModel(title: title, isDone: false)];
  }

  void toggleTodo(int index) {
    state[index] =
        TodoModel(title: state[index].title, isDone: !state[index].isDone);
    state = [...state];
  }

  void delete(int index) {
    state.removeAt(index);
    state = [...state];
  }

  void updateTitle(int index, {required String updateTitle}) {
    state[index] = TodoModel(title: updateTitle, isDone: state[index].isDone);
    state = [...state];
  }
}

// to access the TodoNotifers states and functions \\
final NotifierProvider<TodoNotifier, List<TodoModel>> todoNotifierProvider =
    NotifierProvider<TodoNotifier, List<TodoModel>>(() => TodoNotifier());

// Shopping Cart \\
class ShoppingCartModel {
  final String itemName;
  final double itemPrice;
  final int itemQty;

  ShoppingCartModel(
      {required this.itemName, required this.itemPrice, required this.itemQty});
}

final groceryData = [
  ShoppingCartModel(itemName: "Mango", itemPrice: 20, itemQty: 0),
  ShoppingCartModel(itemName: "banana", itemPrice: 25, itemQty: 0),
  ShoppingCartModel(itemName: "lichi", itemPrice: 30, itemQty: 0),
  ShoppingCartModel(itemName: "apple", itemPrice: 35, itemQty: 0),
  ShoppingCartModel(itemName: "coconut", itemPrice: 40, itemQty: 0),
];

class ShoppingCartNotifer extends Notifier<List<ShoppingCartModel>> {
  @override
  List<ShoppingCartModel> build() {
    return groceryData;
  }

  void addToCart(ShoppingCartModel singleItem) {
    int singleItemindex =
        state.indexWhere((element) => element.itemName == singleItem.itemName);

    if (state[singleItemindex].itemName == singleItem.itemName) {
      if (kDebugMode) {
        print("This is the $singleItemindex of ${singleItem.itemName}");
      }

      state[singleItemindex] = ShoppingCartModel(
          itemName: state[singleItemindex].itemName,
          itemPrice: state[singleItemindex].itemPrice,
          itemQty: (state[singleItemindex].itemQty) + 1);

      state = [...state];
    }
  }

  void removeFromCart(ShoppingCartModel singleItem) {
    final findeSingleItemIndex =
        state.indexWhere((element) => element.itemName == singleItem.itemName);

    if (state[findeSingleItemIndex].itemQty < 1) {
      state.remove(singleItem);
      state = [...state];
    } else {
      final findeSingleItemIndex = state
          .indexWhere((element) => element.itemName == singleItem.itemName);

      state[findeSingleItemIndex] = ShoppingCartModel(
          itemName: state[findeSingleItemIndex].itemName,
          itemPrice: state[findeSingleItemIndex].itemPrice,
          itemQty: (state[findeSingleItemIndex].itemQty) - 1);

      state = [...state];
    }
  }

  double getTotal() {
    return state.fold(
        0.0,
        (previousValue, element) =>
            previousValue + (element.itemPrice) * (element.itemQty));
  }
}

final NotifierProvider<ShoppingCartNotifer, List<ShoppingCartModel>>
    shoppingCartNotifierProdiver =
    NotifierProvider<ShoppingCartNotifer, List<ShoppingCartModel>>(
  () => ShoppingCartNotifer(),
);

enum SelectedColor { Red, Yellow, Black, White, Pink }

// Color Select With Notifier \\
class ChooseColorNotifer extends Notifier<SelectedColor?> {
  @override
  SelectedColor? build() {
    // TODO: implement build
    return null;
  }

  void chooseColor(SelectedColor color) {
    switch (color) {
      case SelectedColor.Black:
        state = SelectedColor.Black;
        break;

      case SelectedColor.Red:
        state = SelectedColor.Red;
        break;

      case SelectedColor.Yellow:
        state = SelectedColor.Yellow;
        break;

      case SelectedColor.White:
        state = SelectedColor.White;
        break;

      case SelectedColor.Pink:
        state = SelectedColor.Pink;
        break;
    }
  }
}

final NotifierProvider<ChooseColorNotifer, SelectedColor?>
    selectedColorProvider =
    NotifierProvider<ChooseColorNotifer, SelectedColor?>(
  () => ChooseColorNotifer(),
);

// Color Select With State Provider \\
final StateProvider<SelectedColor?> colorChoose =
    StateProvider<SelectedColor?>((ref) {
  return null;
});

List<String> sizeChart = ['S', 'M', 'XL', 'XXL'];
final StateProvider<int?> selectedSizeIndex = StateProvider<int?>((ref) {
  return null;
});
