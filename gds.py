from pathlib import Path
import gdstk

# Define el path absoluto a la carpeta de GDS
gds_path = Path("/home/dnmaldonador/Documents/Materias/Maestria/neural_network/cnn_verilog/tt10_cnn/runs/RUN_2025.01.22_17.54.31/results/final/gds")

# Busca los archivos .gds en esa carpeta
gdss = sorted(gds_path.glob("*.gds"))

# Verifica si encontró archivos
if not gdss:
    print(f"No se encontraron archivos GDS en: {gds_path.resolve()}")
else:
    # Cargar el último archivo GDS encontrado
    library = gdstk.read_gds(gdss[-1])
    top_cells = library.top_level()

    # Guardar y mostrar la vista en SVG
    top_cells[0].write_svg("layout.svg")

    from IPython.display import display, SVG
    display(SVG(filename="layout.svg"))
