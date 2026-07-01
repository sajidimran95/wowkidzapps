import 'package:flutter/material.dart';

import 'package:my_first_app/data/models/product.dart';

import 'package:my_first_app/features/search/pages/search_results_page.dart';



void openProductSearch(

  BuildContext context,

  String query, {

  List<Product>? initialProducts,

}) {

  final trimmed = query.trim();

  if (trimmed.isEmpty && (initialProducts == null || initialProducts.isEmpty)) {

    return;

  }

  Navigator.push(

    context,

    MaterialPageRoute(

      builder: (_) => SearchResultsPage(

        query: trimmed.isNotEmpty ? trimmed : 'Image search',

        initialProducts: initialProducts,

      ),

    ),

  );

}

