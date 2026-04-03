import Foundation

enum PantrySeed {
    static let categories: [PantryCategory] = [
        PantryCategory(
            name: "Produce",
            sortOrder: 0,
            items: [
                PantryItem(name: "Onions", sortOrder: 0),
                PantryItem(name: "Garlic", sortOrder: 1),
                PantryItem(name: "Ginger", sortOrder: 2),
                PantryItem(name: "Lettuce", sortOrder: 3),
                PantryItem(name: "Potatoes", sortOrder: 4),
                PantryItem(name: "Celery", sortOrder: 5),
                PantryItem(name: "Carrot", sortOrder: 6)
            ]
        ),
        PantryCategory(
            name: "Dairy & Fridge",
            sortOrder: 1,
            items: [
                PantryItem(name: "Milk", sortOrder: 0),
                PantryItem(name: "Butter", sortOrder: 1),
                PantryItem(name: "Cream", sortOrder: 2),
                PantryItem(name: "Mustard", sortOrder: 3)
            ]
        ),
        PantryCategory(
            name: "Spices",
            sortOrder: 2,
            items: [
                PantryItem(name: "Cinnamon", sortOrder: 0),
                PantryItem(name: "Peppercorns", sortOrder: 1),
                PantryItem(name: "Cumin seeds", sortOrder: 2),
                PantryItem(name: "Smoked paprika", sortOrder: 3),
                PantryItem(name: "Rosemary", sortOrder: 4),
                PantryItem(name: "Thyme", sortOrder: 5),
                PantryItem(name: "Bay Leaves", sortOrder: 6),
                PantryItem(name: "Coriander seeds", sortOrder: 7),
                PantryItem(name: "Cloves", sortOrder: 8),
                PantryItem(name: "Garlic powder", sortOrder: 9),
                PantryItem(name: "Onion powder", sortOrder: 10),
                PantryItem(name: "Madras curry powder", sortOrder: 11),
                PantryItem(name: "Kosher salt", sortOrder: 12)
            ]
        ),
        PantryCategory(
            name: "Oils, Vinegars & Sauces",
            sortOrder: 3,
            items: [
                PantryItem(name: "Olive oil", sortOrder: 0),
                PantryItem(name: "White vinegar", sortOrder: 1),
                PantryItem(name: "Balsamic vinegar", sortOrder: 2),
                PantryItem(name: "Soy sauce", sortOrder: 3),
                PantryItem(name: "Fish sauce", sortOrder: 4),
                PantryItem(name: "Honey", sortOrder: 5)
            ]
        ),
        PantryCategory(
            name: "Pantry Staples",
            sortOrder: 4,
            items: [
                PantryItem(name: "Flour", sortOrder: 0),
                PantryItem(name: "Starter", sortOrder: 1)
            ]
        ),
        PantryCategory(
            name: "Stock & Cooking",
            sortOrder: 5,
            items: [
                PantryItem(name: "Bones", sortOrder: 0)
            ]
        ),
        PantryCategory(
            name: "Freezer",
            sortOrder: 6,
            items: [
                PantryItem(name: "Frozen broccoli", sortOrder: 0),
                PantryItem(name: "Frozen green beans", sortOrder: 1),
                PantryItem(name: "Frozen Hens", sortOrder: 2),
                PantryItem(name: "Frozen pork roast", sortOrder: 3)
            ]
        )
    ]
}
