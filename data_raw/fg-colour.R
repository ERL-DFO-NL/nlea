## Create fg_colour named vector for functional group colours

fg_colour <- c(
  "#88CCEE",  # light blue  SM BEN
  "#44AA99",  # teal        MED BEN
  "#117733",  # green       LG BEN
  "#332288",  # dark blue   PISC
  "#D55E00",  # orange      PLANKPISC
  "#FFC125",  # mustard     PLANK FIXX
  "#AA4499",  # purple      SHELLFISH
  "black",    # black       TOTAL BIOMASS
  "#0000FF"   # blue        FINFISH
)

names(fg_colour) <- c("Small Benthivore",
                      "Medium Benthivore",
                      "Large Benthivore",
                      "Piscivore",
                      "PlankPiscivore",
                      "Planktivores",
                      "Shellfish",
                      "Total Biomass",
                      "Finfish")

usethis::use_data(fg_colour, overwrite = TRUE)
