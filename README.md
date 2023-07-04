# ates_postgresql

A STANDARDIZED MULTISCALE, FUZZY GIS DATA MODEL FOR ATES ZONING

Eirik Sharp  (esharp@avalancheservices.ca), Cam Campbell, Grant Statham, Bryce Schroers 



The Avalanche Terrain Exposure Scale (ATES) zoning is a critical tool for managing the risk of avalanches and ensuring safety in backcountry travel. While traditionally used in printed formats, such as trailhead signs and paper maps, ATES data is increasingly utilized in digital applications, such as web maps and mobile applications. This paper proposes a standardized GIS data model and a set of topological rules for ATES-related spatial data optimized for existing and anticipated digital use cases.

ATES maps are built around vector representations of ATES features (i.e, routes or zones) and often feature additional spatial datasets representing navigational information such as trailheads, established routes, and points of interest. Additionally, rasterized ATES data generated through automated approaches may also be incorporated. Careful consideration is required when integrating these data layers to ensure the accuracy and reliability of the final ATES map. A standardized GIS data model that provides a consistent way of organizing and representing ATES data would promote interoperability by enabling data to be easily shared and used across different platforms while ensuring that appropriate attribute data is maintained to support existing and anticipated applications. In addition to standardization, this paper proposes a more nuanced and flexible representation of avalanche risk by allowing for fuzzy boundaries between ATES classes. This approach better accommodates the uncertainties and variability inherent in any model of natural hazards.

To establish a standard data model, the paper proposes a specific implementation of an ATES database in PostgreSQL using the POSTGIS extension.  It also defines a set of multiscale topological rules that allow for fuzzy membership in ATES classes. This implementation enables the development and storage of ATES data within a single database, with the required procedures and functions coded in pgSQL. The development of this system also highlights the importance of GIS data modelling in informing decision-making in complex natural systems.


KEYWORDS:	ATES, GIS, Avalanche mapping, Topology, Data model
