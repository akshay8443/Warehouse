import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Lisofy/Warehouse/User/UserProvider/auth_user_provider.dart';

class KeyValueTable extends StatelessWidget {
  final Map<String, String?>? data;
  const KeyValueTable({super.key, this.data});

  @override
  Widget build(BuildContext context) {
    final showAll = context.watch<AuthUserProvider>().showAll;
    final dataEntries = data ?? {};
    final entries = showAll
        ? dataEntries.entries.toList()
        : dataEntries.entries.take(3).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      "📦 Warehouse Details",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.amber.shade400,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      context.read<AuthUserProvider>().toggleShowAll();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade400,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        showAll ? "🔽 View Less" : "🔼 View More",
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Key-Value List with Constraints
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: showAll
                      ? constraints.maxHeight * 0.6
                      : constraints.maxHeight * 0.3,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Key
                            Expanded(
                              flex: 4,
                              child: Text(
                                "${entry.key}:",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Colors.amber.shade300,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),

                            // Value
                            Expanded(
                              flex: 4,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  entry.value ?? "0",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
