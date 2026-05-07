# MeadowKart - Riverpod & Cart Logic Guide

> Ei doc ta banano hoyeche ei project er upor based kore.
> Language: English + Bangla mixed, jeno subidhe bujhte paro.

---

## Part 1: Riverpod kivabe kaaj kore? (How Riverpod Works)

### 1.1 Riverpod maaneye ki?

Riverpod holo Flutter er **State Management** library. einfach bhabe bolte gele:

> Tomar app er data jokhon change hoy, UI ke automatic update kora — ei kaaj tai Riverpod kore.

**Ekta real-life example:**
- Tumi ekta shopping cart app banacho
- User "Add to Cart" button e click korlo
- Cart er count 0 theke 1 hoye gelo
- Ei changed data ta UI te automatic show korte hobe
- Ei kaaj ta-i Riverpod kore dey

### 1.2 Riverpod er 3 ta main concept

```
+-------------------+
|   ProviderScope   |  --> App er sob kichu ke wrap kore (wrapper)
+-------------------+
        |
        v
+-------------------+
|     Provider      |  --> Data store kore (jei data share korbo)
+-------------------+
        |
        v
+-------------------+
|   ref.watch()     |  --> UI te data dekhano (listen kora)
|   ref.read()      |  --> Data ke call/invoke kora (ekbar)
+-------------------+
```

---

### 1.3 Step-by-Step: Ei project e Riverpod kivabe set kora hoyeche

#### Step 1: `ProviderScope` diye app ke wrap koro

File: `lib/features/app.dart`

```dart
class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ProviderScope(   // <--- EITA MUST! Na thakle Riverpod kaaj korbe na
      child: MaterialApp.router(
        routerConfig: RouteManager.router,
      ),
    );
  }
}
```

**Keno?** `ProviderScope` holo Riverpod er "container". Er moddhe sob provider live thake. Bina erRiverpod er kono method kaaj korbe na.

---

#### Step 2: Provider toiri koro (Data store banano)

Ei project e mainly **3 dhoroner Provider** use kora hoyeche:

| Provider Type | Ki kaaj kore | Kothay use hoise |
|---|---|---|
| `Provider` | Simple data dey (read-only) | `cartLocalDataSourceProvider`, `fetchProductsUsecaseProvider` |
| `NotifierProvider` | Data + change er method dey | `cartProvider`, `favouriteProvider`, `searchProductsProvider` |
| `AsyncNotifierProvider` | Async data + change er method dey (API call er jonno) | `productsProvider` |

---

#### Step 3: UI theke data read koro ba watch koro

2 ta way ase data ke access korar:

```dart
// ref.watch() --> Data change hole UI automatic rebuild hoy
final cart = ref.watch(cartProvider);

// ref.read() --> Ekbarei data/method nibe, UI rebuild hobe na
ref.read(cartProvider.notifier).addToCart(product);
```

**Simple rule:**
- `build()` method er moddhe → `ref.watch()` use koro (UI update er jonno)
- Button er `onPressed` er moddhe → `ref.read()` use koro (action er jonno)

---

### 1.4 Provider er 3 ta type detail e

#### Type 1: `Provider` (Simple Read-Only Data)

```dart
// file: lib/features/carts/presentation/provider/cart_provider.dart

final cartLocalDataSourceProvider = Provider<CartLocalDataSource>(
  (ref) => CartLocalDataSourceImpl(),
);
```

**Bhabe bujho:** `Provider` holo ekta simple box jekhane ekta object thake. Kono state change er method nei. Sudhu read kora jay.

**Use case:** Kono dependency inject korar jonno — jemon DataSource, Repository, UseCase.

---

#### Type 2: `NotifierProvider` (Data + Methods)

Eita ei project e **sabcheye beshi use** hoyeche. Cart, Favourite, Search — sob eitai.

**Structure:**

```dart
// 1. Provider declare koro
final cartProvider = NotifierProvider<CartNotifier, List<CartItemModel>>(
  CartNotifier.new,   // Notifier class er constructor
);

// 2. Notifier class banao
class CartNotifier extends Notifier<List<CartItemModel>> {

  @override
  List<CartItemModel> build() {
    // Eita initial state. App open howar shomoy ekbar e call hoy.
    return _cartLocalDataSource.getCartProducts();
  }

  // Ei method gulo diye state change korbi
  void addToCart(ProductEntity product) { ... }
  void removeFromCart(int productId) { ... }
}
```

**Bhabe bujho:**
- `NotifierProvider` holo ekta "shop" jekhane data (state) + data change korar method (add, remove) thake.
- `build()` = shop khulor shomoy ki initial data thakbe.
- `state` = current data jeta UI te dekhacche.
- `state = [...]` = notun data set korle UI automatic update hoy.

**Keno `Notifier` er naam `Notifier`?**
Karon ei class "notify" kore UI ke — "hey UI, amar data change hoyeche, update how!"

---

#### Type 3: `AsyncNotifierProvider` (API call er jonno)

```dart
// file: lib/features/products/presentation/provider/fetch_products_provider.dart

final productsProvider =
    AsyncNotifierProvider<FetchProductsProvider, List<ProductEntity>>(
      FetchProductsProvider.new,
    );

class FetchProductsProvider extends AsyncNotifier<List<ProductEntity>> {
  @override
  FutureOr<List<ProductEntity>> build() {
    return fetchProducts();  // API theke data ane
  }

  Future<List<ProductEntity>> fetchProducts() async {
    state = AsyncLoading();   // Loading state
    // ... API call
    state = AsyncData(products);  // Success state
    // ba
    state = AsyncError(error, stackTrace);  // Error state
  }
}
```

**Bhabe bujho:**
- `AsyncNotifier` holo `Notifier` er bhai, kintu eita **async kaaj** (API call, database) er jonno.
- 3 ta state thake: `AsyncLoading` (hocche), `AsyncData` (hoiche), `AsyncError` (error).

**UI te kivabe use kori:**

```dart
// file: lib/features/products/presentation/prodcuts_view.dart

final filteredProducts = ref.watch(searchProductsProvider);

filteredProducts.when(
  loading: () => CircularProgressIndicator(),     // Data ashar shomoy
  error: (error, stack) => Text('Error!'),         // Error hole
  data: (products) => GridView(...),               // Data asha porjonto
);
```

`.when()` method ta `if-else` er motoi — 3 ta case handle kore.

---

### 1.5 Riverpod Flow Diagram (Full Picture)

```
[User clicks "Add to Cart"]
        |
        v
ref.read(cartProvider.notifier).addToCart(product)
        |
        v
CartNotifier.addToCart() method e jabe
        |
        v
state = [...state, CartItemModel(...)]   <-- Notun state set holo
        |
        v
Hive local storage e save holo (_cartLocalDataSource.addToCart)
        |
        v
Riverpod detect korlo state change hoyeche
        |
        v
Jetotuku UI ref.watch(cartProvider) koreche, ogulo rebuild hobe
        |
        v
[Cart icon er count update hoye gelo!]
```

---

### 1.6 ConsumerWidget vs ConsumerStatefulWidget

Ei project e 2 dhoroner widget dekhacche:

**ConsumerWidget** (Simple, stateless):
```dart
// file: lib/features/carts/presentation/carts_view.dart
class CartsView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {  // ref ase!
    final cart = ref.watch(cartProvider);
    return Scaffold(...);
  }
}
```

**ConsumerStatefulWidget** (Stateful, controller lagle):
```dart
// file: lib/features/products/presentation/prodcuts_view.dart
class ProductsView extends ConsumerStatefulWidget {
  @override
  ConsumerState<ProductsView> createState() => _ProductsViewState();
}

class _ProductsViewState extends ConsumerState<ProductsView> {
  final _searchController = TextEditingController();  // Controller lagbe

  @override
  Widget build(BuildContext context) {
    final filteredProducts = ref.watch(searchProductsProvider);  // ref ase!
    return Scaffold(...);
  }
}
```

**Rule:**普通 `StatelessWidget` er jagay `ConsumerWidget` use koro jokhon Riverpod er data lagbe. `StatefulWidget` er jagay `ConsumerStatefulWidget`. Taholei `ref` pabe.

---

### 1.7 `ref.watch` vs `ref.read` vs `ref.invalidate`

| Method | Ki korbe | Kothay use korbi |
|---|---|---|
| `ref.watch(provider)` | Data change hole UI rebuild korbe | `build()` method er moddhe |
| `ref.read(provider)` | Ekbarei data/method nibe, listen korbe na | Button click, callback er moddhe |
| `ref.read(provider.notifier).method()` | Notifier er method call korbe | Action korar jonno |
| `ref.invalidate(provider)` | Provider ke reset/refresh korbe | Retry button, pull-to-refresh |

---

## Part 2: Cart Logic kivabe kaaj kore (Add/Remove Cart)

### 2.1 Cart er Architecture (Big Picture)

```
+------------------------------------------------------------------+
|                        CART ARCHITECTURE                          |
+------------------------------------------------------------------+
|                                                                  |
|  [UI Layer]                                                      |
|    ProductCard --> "Add" button click                            |
|    CartsView   --> Cart items dekhano + remove/quantity change   |
|    CartItemCard--> + / - button e quantity change                |
|                                                                  |
|  [Provider Layer]                                                |
|    CartNotifier --> State manage kore (List<CartItemModel>)      |
|                                                                  |
|  [Data Layer]                                                    |
|    CartLocalDataSourceImpl --> Hive box e data save/load kore    |
|                                                                  |
|  [Storage]                                                       |
|    Hive Box('carts') --> Local storage e cart items save thake   |
|                                                                  |
+------------------------------------------------------------------+
```

### 2.2 Cart er Data Model

File: `lib/features/carts/data/model/cart_model/cart_item_model.dart`

```dart
@freezed
@HiveType(typeId: 2)
class CartItemModel with _$CartItemModel {
  const CartItemModel._();

  const factory CartItemModel({
    @HiveField(0) required ProductEntity product,  // Kon product
    @HiveField(1) required int quantity,            // Koyta
  }) = _CartItemModel;

  double get totalPrice => product.price * quantity;  // Auto calculate!
}
```

**Bhabe bujho:** Ekta cart item holo basically:
- **ProductEntity** = kon product (naam, price, image, etc.)
- **quantity** = koyta ache
- **totalPrice** = `price x quantity` (auto calculated getter)

Example:
```
Product: "T-Shirt", Price: $25.00
Quantity: 3
TotalPrice: $75.00  (25 x 3)
```

---

### 2.3 Cart Provider - Full Breakdown

File: `lib/features/carts/presentation/provider/cart_provider.dart`

#### Provider Declaration:

```dart
final cartProvider = NotifierProvider<CartNotifier, List<CartItemModel>>(
  CartNotifier.new,
);
```

Eitar mane: `CartNotifier` naam er class `List<CartItemModel>` type er state manage korbe.

#### Dependency Provider:

```dart
final cartLocalDataSourceProvider = Provider<CartLocalDataSource>(
  (ref) => CartLocalDataSourceImpl(),
);
```

Cart data Hive e save korar jonno DataSource provide kore.

---

#### Method 1: `addToCart` - Cart e product add kora

```dart
void addToCart(ProductEntity product) {
  // Step 1: Check kor — product ta ki already cart e ache?
  for (var item in state) {
    if (item.product.id == product.id) {
      return;  // Already ache, tai kichu korbo na
    }
  }

  // Step 2: Cart e add koro (quantity = 1 diye)
  _cartLocalDataSource.addToCart(
    CartItemModel(product: product, quantity: 1),
  );

  // Step 3: State update koro (UI refresh hobe)
  state = [...state, CartItemModel(product: product, quantity: 1)];
}
```

**Flow diagram:**
```
User clicks "+" on T-Shirt ($25)
        |
        v
[Is T-Shirt already in cart?]
    |
    +--> YES: return, kichu korbo na
    |
    +--> NO:
            |
            v
        Hive box e save: {product: T-Shirt, quantity: 1}
            |
            v
        state = [old items..., new T-Shirt item]
            |
            v
        UI rebuild: Cart badge shows "1"
```

**Important line:** `state = [...state, newItem]`

Eta ki korche?
- `[...state]` = puran sob item ke spread korlam
- `, newItem]` = tar sathe notun item ta add korlam
- `state = ` = notun list ta state e set korlam
- Ekhane `state =` use na korle UI update hobe NA. Eta Riverpod er rule.

---

#### Method 2: `increaseQuantity` - Quantity barano

```dart
void increaseQuantity(int productId) {
  for (var item in state) {
    if (item.product.id == productId) {
      int index = state.indexOf(item);
      // Notun CartItemModel toiri koro quantity +1 diye
      state[index] = CartItemModel(
        product: item.product,
        quantity: item.quantity + 1,
      );
      // State ke reassign koro (Riverpod ke notify korar jonno)
      state = [...state];
      // Local storage e o update koro
      _cartLocalDataSource.updateCartItem(productId, item.quantity + 1);
    }
  }
}
```

**Flow diagram:**
```
User clicks "+" button on cart item (T-Shirt, qty: 2)
        |
        v
Find T-Shirt in state list
        |
        v
index = position of T-Shirt
state[index] = CartItemModel(product: T-Shirt, quantity: 3)  // 2+1=3
state = [...state]   // Trigger rebuild
Hive update: T-Shirt quantity = 3
        |
        v
UI shows: T-Shirt x 3 = $75.00
```

**Important:** `state = [...state]` eta keno korchi?
- List er moddhe item change korle Riverpod detect korte pare na
- `state = [...state]` kora mane notun list reference toiri korchi
- Riverpod notun reference detect kore UI rebuild kore

---

#### Method 3: `decreaseQuantity` - Quantity komano

```dart
void decreaseQuantity(int productId) {
  for (var item in state) {
    if (item.product.id == productId) {
      if (item.quantity <= 1) {
        // Quantity 1 or less? --> product kei remove koro
        removeFromCart(productId);
        _cartLocalDataSource.removeFromCart(productId);
      } else {
        // Quantity > 1 --> 1 diye komao
        int index = state.indexOf(item);
        state[index] = CartItemModel(
          product: item.product,
          quantity: item.quantity - 1,
        );
        state = [...state];
        _cartLocalDataSource.updateCartItem(productId, item.quantity - 1);
      }
    }
  }
}
```

**Flow diagram:**
```
User clicks "-" button on cart item (T-Shirt, qty: 2)
        |
        v
[Is quantity <= 1?]
    |
    +--> YES (qty = 1):
    |       Remove entire product from cart
    |       Hive theke o delete koro
    |
    +--> NO (qty > 1):
            quantity = quantity - 1 (2-1 = 1)
            state = [...state]  // Trigger rebuild
            Hive update
            |
            v
        UI shows: T-Shirt x 1 = $25.00
```

---

#### Method 4: `removeFromCart` - Product completely remove

```dart
void removeFromCart(int productId) {
  // Je product er id milbe na, shudhu sei items rakho
  state = state.where((item) => item.product.id != productId).toList();
  _cartLocalDataSource.removeFromCart(productId);
}
```

**Flow diagram:**
```
Cart: [T-Shirt, Jeans, Shoes]
                |
    Remove Jeans (id: 5)
                |
                v
state = items where id != 5
=> [T-Shirt, Shoes]    // Jeans chole gelo!
Hive theke o delete
```

---

#### Method 5 & 6: `totalAmount` and `itemCount`

```dart
double get totalAmount =>
    state.fold(0.0, (sum, item) => sum + item.totalPrice);

int get itemCount => state.fold(0, (sum, item) => sum + item.quantity);
```

**`fold()` kivabe kaaj kore:**

Think of it like this:
```
Cart: [T-Shirt(qty:2, $25), Jeans(qty:1, $50)]

totalAmount:
  sum = 0.0
  + T-Shirt: sum = 0 + (25 x 2) = 50
  + Jeans:   sum = 50 + (50 x 1) = 100
  Result: $100.00

itemCount:
  sum = 0
  + T-Shirt: sum = 0 + 2 = 2
  + Jeans:   sum = 2 + 1 = 3
  Result: 3 items
```

---

### 2.4 Local Storage (Hive) kivabe kaaj kore

File: `lib/features/carts/data/datasource/cart_local_datasource/cart_local_data_source.dart`

```dart
class CartLocalDataSourceImpl implements CartLocalDataSource {
  Box<CartItemModel>? _cartBox;

  // Lazy loading: prothom bar access er shomoy box open hobe
  Box<CartItemModel> get _box => _cartBox ??= Hive.box<CartItemModel>('carts');
}
```

**Key methods:**

| Method | Ki korche |
|---|---|
| `addToCart(item)` | Jodi product already thake → quantity 1 barao. Na thakle → notun item add koro |
| `removeFromCart(id)` | Product ID diye delete koro |
| `updateCartItem(id, qty)` | Product er quantity update koro |
| `getCartProducts()` | Sob cart items list akare dao |
| `clearCart()` | Purata cart faka koro |

**App start howar shomoy (main.dart):**
```dart
await Hive.initFlutter();
Hive.registerAdapter(CartItemModelAdapter());  // Model ke register koro
await Hive.openBox<CartItemModel>('carts');     // Box khulo
```

---

### 2.5 UI te kivabe cart dekhacche

#### Products View (Cart badge):
```dart
// file: lib/features/products/presentation/prodcuts_view.dart

// Cart er total item count watch korchi
Consumer(
  builder: (context, ref, _) {
    final count = ref.watch(cartProvider).fold<int>(
      0, (sum, item) => sum + item.quantity,
    );
    if (count == 0) return SizedBox.shrink();  // 0 hole kichu dekhabe na
    return Container(
      child: Text('$count'),  // Count dekhabe
    );
  },
),
```

#### Cart View (Full cart page):
```dart
// file: lib/features/carts/presentation/carts_view.dart

class CartsView extends ConsumerWidget {
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);  // Cart data watch koro
    final totalAmount = ref.read(cartProvider.notifier).totalAmount;
    final itemCount = ref.read(cartProvider.notifier).itemCount;

    // Cart faka? --> Empty state dekhao
    // Cart e item ase? --> ListView + Bottom panel dekhao
  }
}
```

#### Cart Item Card (+ / - buttons):
```dart
// file: lib/features/carts/presentation/widget/cart_item.dart

class CartItemCard extends ConsumerWidget {
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      onDismissed: (_) => ref.read(cartProvider.notifier).removeFromCart(id),
      child: Row(
        children: [
          // "-" button
          _QtyButton(
            icon: Icons.remove_rounded,
            onTap: () => ref.read(cartProvider.notifier).decreaseQuantity(id),
          ),
          // Quantity text
          Text('${item.quantity}'),
          // "+" button
          _QtyButton(
            icon: Icons.add_rounded,
            onTap: () => ref.read(cartProvider.notifier).increaseQuantity(id),
          ),
        ],
      ),
    );
  }
}
```

---

### 2.6 Full Cart Flow (Start to End)

```
+================================================================+
|                    FULL CART FLOW                               |
+================================================================+
|                                                                |
| 1. APP START                                                   |
|    main() --> Hive init --> Box open --> App runs              |
|                                                                |
| 2. USER OPENS PRODUCTS PAGE                                    |
|    ProductsView builds --> ref.watch(searchProductsProvider)   |
|    --> API call --> Products show in grid                      |
|                                                                |
| 3. USER CLICKS "+" ON A PRODUCT                                |
|    ProductCard tap --> ref.read(cartProvider.notifier)         |
|    --> addToCart(product)                                      |
|    --> Check duplicate                                         |
|    --> Save to Hive                                            |
|    --> state = [...state, newItem]                             |
|    --> UI auto-rebuild (cart badge shows count)                |
|                                                                |
| 4. USER GOES TO CART PAGE                                      |
|    CartsView --> ref.watch(cartProvider)                       |
|    --> Shows all cart items                                    |
|    --> Bottom panel shows total price                          |
|                                                                |
| 5. USER CLICKS "+" IN CART (increase quantity)                 |
|    CartItemCard --> ref.read(cartProvider.notifier)            |
|    --> increaseQuantity(productId)                             |
|    --> state[index] = updated item                             |
|    --> state = [...state]                                      |
|    --> Hive update                                             |
|    --> UI rebuild (new quantity + price)                       |
|                                                                |
| 6. USER CLICKS "-" IN CART (decrease quantity)                 |
|    decreaseQuantity(productId)                                 |
|    --> If qty <= 1: removeFromCart()                           |
|    --> If qty > 1: quantity - 1, update state & Hive           |
|                                                                |
| 7. USER SWIPES LEFT (remove product)                           |
|    Dismissible --> onDismissed                                 |
|    --> removeFromCart(productId)                               |
|    --> state = filtered list                                   |
|    --> Hive delete                                             |
|                                                                |
| 8. USER CLICKS "CHECKOUT"                                      |
|    Navigate to Checkout page                                   |
|                                                                |
+================================================================+
```

---

## Part 3: Quick Reference Cheat Sheet

### Riverpod e notun feature add korar steps:

```
Step 1: Model banao        --> (freezed + Hive annotation)
Step 2: DataSource banao   --> (Hive box e save/load logic)
Step 3: Provider banao     --> (NotifierProvider declare koro)
Step 4: Notifier class     --> (build() + methods)
Step 5: UI e watch koro    --> (ref.watch, ref.read)
Step 6: Test koro!
```

### Common Riverpod patterns ei project e:

| Pattern | Example |
|---|---|
| Simple dependency | `Provider<DataSource>((ref) => DataSourceImpl())` |
| State with methods | `NotifierProvider<Notifier, StateType>(Notifier.new)` |
| Async data (API) | `AsyncNotifierProvider<Notifier, List<Item>>(Notifier.new)` |
| Watch in UI | `ref.watch(cartProvider)` |
| Call method | `ref.read(cartProvider.notifier).addToCart(product)` |
| Reset provider | `ref.invalidate(productsProvider)` |
| Computed value | `state.fold(0, (sum, item) => sum + item.totalPrice)` |

---

## Part 4: Common Mistakes & Tips

### Mistake 1: `ProviderScope` bhule jaoa
```dart
// WRONG - Riverpod kaaj korbe na
runApp(const App());

// RIGHT
runApp(const ProviderScope(child: App()));
```

### Mistake 2: `ref.watch` button er moddhe use kora
```dart
// WRONG - Build er moddhe watch kora uchit, button e na
onPressed: () => ref.watch(cartProvider)  // NA!

// RIGHT - Button e read koro
onPressed: () => ref.read(cartProvider.notifier).addToCart(product)
```

### Mistake 3: `state` directly modify kora
```dart
// WRONG - Riverpod detect korbe na
state[0] = newItem;

// RIGHT - Notun list reference toiri koro
state[0] = newItem;
state = [...state];  // Eta MUST!
```

### Mistake 4: `ConsumerWidget` er bodole `StatelessWidget` use kora
```dart
// WRONG - ref pabe na
class MyWidget extends StatelessWidget {
  Widget build(BuildContext context) {
    ref.watch(...);  // ERROR: ref nei!
  }
}

// RIGHT - ConsumerWidget use koro
class MyWidget extends ConsumerWidget {
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(...);  // OK!
  }
}
```

---

## Summary (Shongkhep)

| Topic | Key Point |
|---|---|
| Riverpod ki? | Flutter er State Management library |
| Provider ki? | Data store jeta share kora jay |
| `ref.watch` | Data change hole auto rebuild |
| `ref.read` | Ekbarei data/method nibe |
| `NotifierProvider` | Data + change method (Cart, Favourite) |
| `AsyncNotifierProvider` | API call er jonno (Products) |
| Cart Add | Check duplicate → Save Hive → Update state |
| Cart Remove | Filter state → Delete Hive |
| Quantity +/- | Update index → Reassign state → Update Hive |
| `state = [...]` | UI rebuild trigger korar MUST line |

---

> **Last tip:** Riverpod shikhar shobcheye bhalo way holo ei project er code ta ekta ekta kore read kora. Ei doc ta read korar por, actual code e giye line by line follow koro. Codeshob bujhe jabe!

---

*Generated for MeadowKart Project*
