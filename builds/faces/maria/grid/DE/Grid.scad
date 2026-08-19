module grid() {
    linear_extrude(height = 12, center = false, convexity = 100)
        scale(1.333)
            import(file = "Grid.svg", layer = "plate", dpi = 72);
}

grid();