using System.Diagnostics;
using System.Text;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;

namespace StacksOfSnaps
{
    /// <summary>
    /// Interaction logic for MainWindow.xaml
    /// </summary>
    public partial class MainWindow : Window
    {
        public MainWindow()
        {
            InitializeComponent();
        }

        private void ExecuteButton_Click(object sender, RoutedEventArgs e)
        {
            string command = CommandInput.Text.Trim();
            
            if (string.IsNullOrEmpty(command))
            {
                OutputDisplay.Text = "Please enter a command to execute.";
                return;
            }

            try
            {
                ExecuteButton.IsEnabled = false;
                OutputDisplay.Text = "Executing command...\n";

                ProcessStartInfo processInfo = new ProcessStartInfo
                {
                    FileName = "cmd.exe",
                    Arguments = $"/c {command}",
                    RedirectStandardOutput = true,
                    RedirectStandardError = true,
                    UseShellExecute = false,
                    CreateNoWindow = true
                };

                using (Process process = new Process())
                {
                    process.StartInfo = processInfo;
                    
                    StringBuilder output = new StringBuilder();
                    StringBuilder error = new StringBuilder();

                    process.OutputDataReceived += (s, args) =>
                    {
                        if (args.Data != null)
                            output.AppendLine(args.Data);
                    };

                    process.ErrorDataReceived += (s, args) =>
                    {
                        if (args.Data != null)
                            error.AppendLine(args.Data);
                    };

                    process.Start();
                    process.BeginOutputReadLine();
                    process.BeginErrorReadLine();
                    process.WaitForExit();

                    string result = output.ToString();
                    string errorOutput = error.ToString();

                    if (!string.IsNullOrEmpty(errorOutput))
                    {
                        OutputDisplay.Text = $"Error:\n{errorOutput}\n\nOutput:\n{result}";
                    }
                    else if (!string.IsNullOrEmpty(result))
                    {
                        OutputDisplay.Text = result;
                    }
                    else
                    {
                        OutputDisplay.Text = "Command executed successfully with no output.";
                    }
                }
            }
            catch (Exception ex)
            {
                OutputDisplay.Text = $"Error executing command:\n{ex.Message}";
            }
            finally
            {
                ExecuteButton.IsEnabled = true;
            }
        }
    }
}