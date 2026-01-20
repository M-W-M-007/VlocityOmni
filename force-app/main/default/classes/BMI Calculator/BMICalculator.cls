/**
 * BMICalculator
 *
 * Open Interface for OmniStudio to calculate BMI from Weight and Height inputs.
 *
 * Inputs (input Map keys):
 * - Weight: Decimal or String parsable to Decimal
 * - Height: Decimal or String parsable to Decimal (meters)
 *
 * Outputs (output Map keys):
 * - CalculatedBMI: Decimal (2 decimal places)
 * - BMICategory: String (Underweight | Normal weight | Overweight | Obese)
 * - success: Boolean
 * - message: String (optional, error or info)
 */
public with sharing class BMICalculator implements Callable {

    // Main entry point for the Callable interface
    public Object call(String action, Map<String, Object> args) {
        Map<String, Object> input = (Map<String, Object>) args.get('input');
        Map<String, Object> output = (Map<String, Object>) args.get('output');
        
        if (action.equals('calculateBMI')) {
            calculateBMI(input, output);
            return true;
        }
        return false;
    }

    // Changed return type to void since we are modifying the 'output' map directly
    private void calculateBMI(Map<String, Object> input, Map<String, Object> output) {
        try {
            Object wObj = input.get('Weight');
            Object hObj = input.get('Height');

            if (wObj == null || hObj == null) {
                output.put('BMIError', 'Missing Input: Weight or Height');
                return;
            }

            Decimal weight = Decimal.valueOf(String.valueOf(wObj));
            Decimal height = Decimal.valueOf(String.valueOf(hObj));

            if (height > 0) {
                // Calculation: kg / m^2
                Decimal bmi = weight / (height * height);
                bmi = bmi.setScale(2);
                
                output.put('CalculatedBMI', bmi);
                output.put('BMICategory', getCategory(bmi));
            } else {
                output.put('BMIError', 'Height must be greater than zero');
            }
        } catch (Exception e) {
            output.put('BMIError', 'Exception: ' + e.getMessage());
        }
    }

    private String getCategory(Decimal bmi) {
        if (bmi < 18.5) return 'Underweight';
        if (bmi < 25) return 'Normal weight';
        if (bmi < 30) return 'Overweight';
        return 'Obese';
    }
}
