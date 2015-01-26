//    Integer[][] test_codes = new Integer[3][3];
//    test_codes[0] = new Integer[3];
//    test_codes[0][0] = 1;
//    test_codes[0][1] = 1;
//    test_codes[0][2] = 1;
//    
//    
//    test_codes[1][0] = 1;
//    test_codes[1][1] = 0;
//    test_codes[1][2] = 1;
//    
//    test_codes[2][0] = 1;
//    test_codes[2][1] = 0;
//    test_codes[2][2] = 1;
//    print("input0:\t" + test_codes[0][0] + "," + test_codes[0][1] + "," + test_codes[0][2] + "\n");
//    print("input1:\t" + test_codes[1][0] + "," + test_codes[1][1] + "," + test_codes[1][2] + "\n");
//    print("input2:\t" + test_codes[1][0] + "," + test_codes[1][1] + "," + test_codes[1][2] + "\n");
//    Integer[] learn_code = learnCode(test_codes);
//    print("learned:\t" + learn_code[0] + "," + learn_code[1] + "," + learn_code[2] + "\n");
//    
//    print("input1 match code? " + matchCode(test_codes[0], learn_code) + "\n");
//    print("input1 match input2? " + matchCode(test_codes[0], test_codes[1]) + "\n");
//    print("input2 match input3? " + matchCode(test_codes[1], test_codes[2]) + "\n");
    

//Integer[] learnCode(List[Integer] inputCodes[][]) {
//  int nrow = inputCodes.length;
//  int ncol = inputCodes[0].length;
//  
//  Integer code = null;
////  Integer lastLearned = null;
//  
//  Integer[] learnedCode = new Integer[ncol];
//  for (int c=0; c<ncol; c++) {
//   for (int r=0; r<nrow; r++) {
//     if (inputCodes[r].length != ncol) {
//        throw new java.lang.IllegalArgumentException(); // throw error
//     }
//     
//     if (r==0) { 
//         code = inputCodes[r][c];
//         learnedCode[c] = code;
//     } else {
//       if (code != inputCodes[r][c]) {
//           learnedCode[c] = null;
//       }
//     }
//   } 
//  }
//  return learnedCode;
//}
//
//boolean matchCode(Integer[] inputCode, Integer[] learnedCode) {
//  int ncol = inputCode.length;
//  if (ncol != learnedCode.length) {
//   throw new java.lang.IllegalArgumentException(); 
//  }
//  for (int c=0; c<ncol; c++) {
//   if (learnedCode[c] != null &&
//        learnedCode[c] != inputCode[c]) {
//      return false;   
//    } 
//  }
//  
//  return true;
//}


//    Integer[] tcode1_in = new Integer[3];
//    tcode1_in[0] = 1;
//    tcode1_in[1] = 1;
//    tcode1_in[2] = 1;
//    Code tcode1 = new Code(tcode1_in);
//    
//    tcode1_in[2] = 0;
//    Code tcode2 = new Code(tcode1_in);
//    
//    
//    List<Code> incodes = new ArrayList<Code>();
//    incodes.add(tcode1);
//    incodes.add(tcode2);
//    Code lcode = Code.learnCode(incodes);
//    
//    println(tcode1.code);
//    println(tcode2.code);
//    println(lcode.code);

import java.util.List;

static class Code {
  public Integer[] code;
  public int len;
  
  public Code(Integer[] code) {
    int clen = code.length;
    this.code = new Integer[clen];
    for (int i=0; i<clen; i++) {
     this.code[i] = code[i]; 
    }
    this.len = code.length;
  }
  
  public boolean matchCode(Code target) {
    int ncol = target.len;
    if (ncol != this.len) {
     throw new java.lang.IllegalArgumentException(); 
    }
    for (int c=0; c<ncol; c++) {
     if (target.code[c] != null &&
          this.code[c] != target.code[c]) {
        return false;   
      } 
    }
    
    return true;
  }
  
  static Code learnCode(List<Code> inputCodes) {
  //  Integer[] learnCode(List[Integer] inputCodes[][]) {
    int nrow = inputCodes.size();
    int ncol = inputCodes.get(0).len;
    
    Integer code = null;
  //  Integer lastLearned = null;
    
    Integer[] learnedCode = new Integer[ncol];
    for (int c=0; c<ncol; c++) {
     for (int r=0; r<nrow; r++) {
       if (inputCodes.get(r).len != ncol) {
          throw new java.lang.IllegalArgumentException(); // throw error
       }
       
       if (r==0) { 
           code = inputCodes.get(r).code[c];
           learnedCode[c] = code;
       } else {
         if (code != inputCodes.get(r).code[c]) {
             learnedCode[c] = null;
         }
       }
     } 
    }
    Code lcode = new Code(learnedCode);
    return lcode;
  }
}


