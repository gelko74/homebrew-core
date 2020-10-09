class TerraformLs < Formula
  desc "Terraform Language Server"
  homepage "https://github.com/hashicorp/terraform-ls"
  url "https://github.com/hashicorp/terraform-ls/archive/v0.8.0.tar.gz"
  sha256 "cb66eeee6cac1677a9283405b6b5258c85d752528fd460fcb10021bf2c656fda"
  license "MPL-2.0"
  head "https://github.com/hashicorp/terraform-ls.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "e5e92a86843dd8d4f4fa6d2dca6c1e47a3e94bb6f0b838d4a17e8d0d36f18b16" => :catalina
    sha256 "0a214bc2d98d118c45580bcc0ed26fe70c4165060582ec78874568d8a39ba097" => :mojave
    sha256 "54188518877df63f844bb00bd71a5613299e0cefe8bd50459c2fe67901f7e6a6" => :high_sierra
  end

  depends_on "go" => :build

  def install
    system "go", "build", *std_go_args, "-ldflags", "-s -w"
  end

  test do
    port = free_port

    pid = fork do
      exec "#{bin}/terraform-ls serve -port #{port} /dev/null"
    end
    sleep 2

    begin
      tcp_socket = TCPSocket.new("localhost", port)
      tcp_socket.puts <<~EOF
        Content-Length: 59

        {"jsonrpc":"2.0","method":"initialize","params":{},"id":1}
      EOF
      assert_match "Content-Type", tcp_socket.gets("\n")
    ensure
      Process.kill("SIGINT", pid)
      Process.wait(pid)
    end
  end
end
