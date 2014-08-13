angular.module('ndApp')
  .service 'AssaysService', ->
    Assays = [
      {
        name: "BCR_ABL_monitor",
        label: "Xpert BCR-ABL Monitor",
        valid_values:
          options: [
            {value: "positive", label: "Detected"}
          ]
      },
      {
        name: "C_difficile",
        label: "Xpert C. difficile",
        valid_values:
          options: [
            {value: "positive", label: "C.diff positive & 027 presumptive neg"},
            {value: "pos_presum_O27", label: "C.diff positive & 027 presumptive pos"}
          ]
      },
      {
        name: "CT",
        label: "Xpert CT",
        valid_values:
          options: [
            {value: "positive", label: "CT Detected"}
          ]
      },
      {
        name: "CT_NG",
        label: "Xpert CT/NG",
        valid_values:
          options: [
            {value: "positive_CT", label: "CT only detected"},
            {value: "positive_NG", label: "NG only detected"},
            {value: "positive_CT_NG", label: "CT & NG detected"}
          ]
      },
      {
        name: "EV",
        label: "Xpert EV",
        valid_values:
          options: [
            {value: "positive", label: "Positive"}
          ]
      },
      {
        name: "FII_FV",
        label: "Xpert FII & FV",
        valid_values:
          options: [
            {value: "positive", label: "Other results"}
          ]
      },
      {
        name: "flu",
        label: "Xpert Flu",
        valid_values:
          options: [
            {value: "positive_fluA", label: "Positive FluA"},
            {value: "positive_fluB", label: "Positive FluB"},
            {value: "positive_H1N1", label: "Positive FluA & 2009 H1N1 Detected"},
            {value: "pos_fluA_fluB", label: "Positive FluA & FluB"},
            {value: "pos_H1N1_fluB", label: "Positive FluA & 2009 H1N1 Detected & FluB"}
          ]
      },
      {
        name: "flu_rsv_xc_flu",
        label: "Xpert Flu/RSV XC (Flu only)",
        valid_values:
          options: [
            {value: "positive_fluA", label: "Flu A Positive & Flu B Negative"},
            {value: "positive_fluB", label: "Flu A Negative & Flu B Positive"},
            {value: "pos_fluA_fluB", label: "Flu A Positive & Flu B Positive"}
          ]
      },
      {
        name: "flu_rsv_xc_full",
        label: "Xpert Flu/RSV XC (Full)",
        valid_values:
          options: [
            {value: "positive_fluA", label: "Flu A Positive, Flu B Negative & Flu RSV Negative"},
            {value: "positive_fluB", label: "Flu A Negative, Flu B Positive & Flu RSV Negative"},
            {value: "pos_fluA_fluB", label: "Flu A Positive, Flu B Positive & Flu RSV Negative"},
            {value: "positive_rsv", label: "Flu A Negative, Flu B Negative & Flu RSV Positive"},
            {value: "pos_fluA_rsv", label: "Flu A Positive, Flu B Negative & Flu RSV Positive"},
            {value: "pos_fluB_rsv", label: "Flu A Negative, Flu B Positive & Flu RSV Positive"},
            {value: "pos_fluA_fluB_rsv", label: "Flu A Positive, Flu B Positive & Flu RSV Positive"}
          ]
      },
      {
        name: "GBS",
        label: "Xpert GBS",
        valid_values:
          options: [
            {value: "positive", label: "Positive"}
          ]
      },
      {
        name: "GBS_LB",
        label: "Xpert GBS LB",
        valid_values:
          options: [
            {value: "positive", label: "GBS Positive"}
          ]
      },
      {
        name: "HCV_quant",
        label: "Xpert HCV Quant",
        valid_values:
          options: [
            {value: "positive", label: "Detected"}
          ]
      },
      {
        name: "HIV_qual",
        label: "Xpert HIV Qual",
        valid_values:
          options: [
            {value: "positive", label: "Detected"}
          ]
      },
      {
        name: "HIV_quant",
        label: "Xpert HIV Quant",
        valid_values:
          options: [
            {value: "positive", label: "Detected"}
          ]
      },
      {
        name: "HPV_HR_16_18_45",
        label: "Xpert HPV HR_16_18-45",
        valid_values:
          options: [
            {value: "pos_hpv_16", label: "HPV 16 POS, HPV 18-45 NEG & Other HR HPV NEG"},
            {value: "pos_hpv_18_45", label: "HPV 16 NEG, HPV 18-45 POS & Other HR HPV NEG"},
            {value: "pos_hr", label: "HPV 16 NEG, HPV 18-45 NEG & Other HR HPV POS"},
            {value: "pos_hpv_16_hr", label: "HPV 16 POS, HPV 18-45 NEG & Other HR HPV POS"},
            {value: "pos_hpv_18_45_hr", label: "HPV 16 NEG, HPV 18-45 POS & Other HR HPV POS"},
            {value: "pos_hpv_16_18_45_hr", label: "HPV 16 POS, HPV 18-45 POS & Other HR HPV POS"},
            {value: "pos_hpv_16_18_45", label: "HPV 16 POS, HPV 18-45 POS & Other HR HPV NEG"}
          ]
      },
      {
        name: "HPV_HR",
        label: "Xpert HPV HR",
        valid_values:
          options: [
            {value: "positive", label: "HR HPV POS"}
          ]
      },
      {
        name: "HPV_16_18_45",
        label: "Xpert HPV 16_18-45",
        valid_values:
          options: [
            {value: "pos_hpv_16", label: "HPV 16 POS & HPV 18-45 NEG"},
            {value: "pos_hpv_18_45", label: "HPV 16 NEG & HPV 18-45 POS"},
            {value: "pos_hpv_16_18_45", label: "HPV 16 POS & HPV 18-45 POS"}
          ]
      },
      {
        name: "MRSA_plain",
        label: "Xpert MRSA",
        valid_values:
          options: [
            {value: "positive", label: "Positive"}
          ]
      },
      {
        name: "MRSA_nasal",
        label: "Xpert MRSA/SA Nasal Complete",
        valid_values:
          options: [
            {value: "positive_SA", label: "Positive SA"},
            {value: "pos_SA_MRSA", label: "Positive MRSA"}
          ]
      },
      {
        name: "MRSA_SSTI",
        label: "Xpert MRSA/SA SSTI",
        valid_values:
          options: [
            {value: "positive_SA", label: "Positive SA"},
            {value: "pos_SA_MRSA", label: "Positive MRSA"}
          ]
      },
      {
        name: "MRSA_BC",
        label: "Xpert MRSA/SA BC",
        valid_values:
          options: [
            {value: "positive_SA", label: "Positive SA"},
            {value: "pos_SA_MRSA", label: "Positive MRSA"}
          ]
      },
      {
        name: "MTB_RIF",
        label: "Xpert MTB/RIF",
        valid_values:
          options: [
            {value: "positive", label: "MTB detected & RIF not detected"},
            {value: "pos_RIF_inconclusive", label: "MTB detected & RIF indeterminate"},
            {value: "pos_with_RIF", label: "MTB detected & RIF detected"}
          ]
      },
      {
        name: "norovirus",
        label: "Xpert Norovirus",
        valid_values:
          options: [
            {value: "pos_gi", label: "Noro GI Detected & Noro GII not detected"},
            {value: "pos_gii", label: "Noro GI not detected & Noro GII Detected"},
            {value: "pos_gi_gii", label: "Noro GI Detected & Noro GII Detected"}
          ]
      },
      {
        name: "vanA_vanB",
        label: "Xpert vanA/vanB",
        valid_values:
          options: [
            {value: "positive_vanA", label: "Positive VanA"},
            {value: "positive_vanB", label: "Positive VanB"},
            {value: "pos_vanA_vanB", label: "Positive VanA & VanB"}
          ]
      },
    ]

    service =
      all: ->
        Assays

      find: (name) ->
        for assay in Assays
          if assay.name == name
            return assay
        null

      optionsFor: (name) ->
        service.find(name).valid_values.options

      valuesFor: (name) ->
        _.map service.optionsFor(name), (option) -> option.value
